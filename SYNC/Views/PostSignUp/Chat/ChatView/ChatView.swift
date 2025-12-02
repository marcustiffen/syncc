import SwiftUI
import Combine
import FirebaseFirestore

struct ChatView: View {
    @EnvironmentObject private var profileModel: ProfileModel
    @EnvironmentObject private var messagesManager: MessagesManager
    @StateObject private var matchMakingManager = MatchMakingManager()
    @Environment(\.dismiss) var dismiss
    
    let messageReceiver: DBUser
    let chatRoomId: String
    
    // MARK: - State
    @State private var scrollProxy: ScrollViewProxy?
    @State private var selectedOption: MenuOption = .unmatch
    @State private var showDeleteConfirmation = false
    @State private var navigateToReportScreen = false
    @State private var showInspectView = false
    @State private var hasScrolledToBottom = false
    @State private var keyboardHeight: CGFloat = 0
    
    // MARK: - Computed Properties
    var usersFirstName: String {
        messageReceiver.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    enum MenuOption: String, CaseIterable {
        case unmatch = "Unmatch"
        case block = "Block"
        case report = "Report User"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            header
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white)
            
            Divider()
            
            // MARK: - Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedMessages, id: \.id) { group in
                            MessageGroupView(
                                group: group,
                                currentUserId: profileModel.user?.uid ?? ""
                            )
                        }
                        
                        // Invisible anchor at bottom
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .onAppear {
                    scrollProxy = proxy
                    // Force immediate scroll on first appear
                    if !messagesManager.messages.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                            hasScrolledToBottom = true
                        }
                    }
                }
                .onChange(of: messagesManager.messages) { oldValue, newValue in
                    handleMessagesChange(oldMessages: oldValue, newMessages: newValue, proxy: proxy)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            
            // MARK: - Message Input
            ExpandableMessageInputView(
                chatRoomId: chatRoomId,
                messageReceiver: messageReceiver,
                messagesManager: messagesManager
            )
            .environmentObject(profileModel)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Wait!"),
                message: Text(alertMessage),
                primaryButton: .destructive(Text(selectedOption.rawValue)) {
                    handleMenuAction()
                },
                secondaryButton: .cancel()
            )
        }
        .navigationDestination(isPresented: $showInspectView) {
            ChatInspectUserView(showInspectView: $showInspectView, user: messageReceiver)
        }
        .sheet(isPresented: $navigateToReportScreen) {
            NavigationStack {
                ReportView(reportedUser: messageReceiver)
            }
        }
        .onReceive(messagesManager.$messages) { messages in
            markUnseenMessages(messages)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            SyncBackButton { dismiss() }
            Spacer()
            Text(usersFirstName)
                .foregroundStyle(.syncBlack)
                .onTapGesture {
                    showInspectView = true
                }
            Spacer()
            
            Menu {
                ForEach(MenuOption.allCases, id: \.self) { option in
                    Button {
                        selectedOption = option
                        if selectedOption == .report {
                            navigateToReportScreen = true
                        } else {
                            showDeleteConfirmation = true
                        }
                    } label: {
                        Text(option.rawValue)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
            }
            .tint(.syncBlack)
        }
        .h1Style()
    }
    

    private var groupedMessages: [MessageGroup] {
        var groups: [MessageGroup] = []
        var currentGroup: [Message] = []
        var currentSenderId: String?
        
        for (index, message) in messagesManager.messages.enumerated() {
            let isNewGroup = currentSenderId != message.senderId
            
            if isNewGroup {
                // Save previous group
                if !currentGroup.isEmpty, let senderId = currentSenderId {
                    groups.append(MessageGroup(
                        id: UUID().uuidString,
                        messages: currentGroup,
                        senderId: senderId,
                        isLastOverall: false
                    ))
                }
                // Start new group
                currentGroup = [message]
                currentSenderId = message.senderId
            } else {
                currentGroup.append(message)
            }
            
            // Handle last message
            if index == messagesManager.messages.count - 1 {
                groups.append(MessageGroup(
                    id: UUID().uuidString,
                    messages: currentGroup,
                    senderId: message.senderId,
                    isLastOverall: true
                ))
            }
        }
        
        return groups
    }
    
    // MARK: - Scroll Handling
    private func handleMessagesChange(oldMessages: [Message], newMessages: [Message], proxy: ScrollViewProxy) {
        // Initial load - scroll when messages first arrive (if not already scrolled from onAppear)
        if oldMessages.isEmpty && !newMessages.isEmpty && !hasScrolledToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                proxy.scrollTo("bottom", anchor: .bottom)
                hasScrolledToBottom = true
            }
        }
        // New message arrived - smooth scroll
        else if newMessages.count > oldMessages.count && hasScrolledToBottom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollToBottom(proxy: proxy, animated: true)
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        } else {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
    
    // MARK: - Message Marking
    private func markUnseenMessages(_ messages: [Message]) {
        let filteredMessages = messages.filter {
            $0.senderId != profileModel.user?.uid && $0.seen == false
        }
        
        if !filteredMessages.isEmpty {
            messagesManager.makeMessagesSeen(receivedMessages: filteredMessages)
        }
    }
    
    // MARK: - Alert & Actions
    private var alertMessage: String {
        switch selectedOption {
        case .unmatch:
            return "Are you sure you want to unmatch with \(messageReceiver.name ?? "")?"
        case .block:
            return "Are you sure you want to block \(messageReceiver.name ?? "")? They will no longer be able to contact you."
        case .report:
            return ""
        }
    }
    
    private func handleMenuAction() {
        guard let currentUserId = profileModel.user?.uid else { return }
        
        switch selectedOption {
        case .unmatch, .block:
            matchMakingManager.unmatchUser(currentUserId: currentUserId, unmatchedUserId: messageReceiver.uid) { result in
                switch result {
                case .success:
                    dismiss.callAsFunction()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .report:
            print("Reported")
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}




