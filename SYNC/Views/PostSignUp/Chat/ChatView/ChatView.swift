import SwiftUI
import Combine
import FirebaseFirestore


struct ChatView: View {
    @EnvironmentObject private var profileModel: ProfileModel
    @EnvironmentObject private var messagesManager: MessagesManager
    @StateObject private var matchMakingManager = MatchMakingManager()
//    @State private var showPayWallView = false
    
    @Environment(\.dismiss) var dismiss
    
    let messageReceiver: DBUser
    let chatRoomId: String
    
    var usersFirstName: String {
        return messageReceiver.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    @State private var hasMarkedMessagesSeen = false
    @State private var scrollProxy: ScrollViewProxy?
    
    enum MenuOption: String, CaseIterable {
        case unmatch = "Unmatch"
        case block = "Block"
        case report = "Report User"
    }
    
    @State private var selectedOption: MenuOption = .unmatch
    @State private var showDeleteConfirmation = false
    @State private var navigateToReportScreen = false
    @State private var showInspectView = false
    
    var body: some View {
        VStack {
            HStack {
                SyncBackButton { dismiss() }
                Spacer()
                Text("\(String(describing: usersFirstName))")
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
            .padding(.horizontal, 10)
            
            Spacer()

            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack {
                        ForEach(messagesManager.messages.indices, id: \.self) { index in
                            let message = messagesManager.messages[index]
                            let isLastMessage = (index == messagesManager.messages.count - 1)
                            
                            // NEW: Determine if this is the last message in a consecutive sequence
                            let isLastInSequence: Bool = {
                                // If this is the last message overall, it's the last in sequence
                                if index == messagesManager.messages.count - 1 {
                                    return true
                                }
                                
                                // Check if the next message is from a different sender
                                let nextMessage = messagesManager.messages[index + 1]
                                return message.senderId != nextMessage.senderId
                            }()
                            
                            MessageBubbleView(
                                message: message,
                                isLastMessage: isLastMessage,
                                isLastInSequence: isLastInSequence
                            )
                            .id(index)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .onChange(of: messagesManager.messages.count) {
                        withAnimation {
                            proxy.scrollTo(messagesManager.messages.count - 1)
                        }
                    }
                }
            }
            .animation(.easeIn, value: messagesManager.messages.count)
            .padding(.horizontal, 10)
            
            MessageFieldView(
                messages: $messagesManager.messages,
                chatRoomId: chatRoomId,
                messageReceiver: messageReceiver,
                messagesManager: messagesManager // Pass the messages manager
            )
            .environmentObject(profileModel)
            .frame(maxWidth: .infinity)
        }
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
        .navigationDestination(isPresented: $showInspectView, destination: {
            ChatInspectUserView(showInspectView: $showInspectView, user: messageReceiver)
        })
        .sheet(isPresented: $navigateToReportScreen, content: {
            NavigationStack {
                ReportView(reportedUser: messageReceiver)
            }
        })
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.white.ignoresSafeArea()
        )
        .onReceive(messagesManager.$messages) { messages in
            let filteredMessages = messages.filter {
                $0.senderId != profileModel.user?.uid && $0.seen == false
            }
            
            if !messages.isEmpty {
                messagesManager.makeMessagesSeen(receivedMessages: filteredMessages)
            }
        }
    }
    
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
        case .unmatch:
            matchMakingManager.unmatchUser(currentUserId: currentUserId, unmatchedUserId: messageReceiver.uid) { result in
                switch result {
                case .success:
                    dismiss.callAsFunction()
                    print("Unmatched user")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .block:
            matchMakingManager.unmatchUser(currentUserId: currentUserId, unmatchedUserId: messageReceiver.uid) { result in
                switch result {
                case .success:
                    dismiss.callAsFunction()
                    print("Unmatched user")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .report:
            print("Reported")
        }
    }
}
