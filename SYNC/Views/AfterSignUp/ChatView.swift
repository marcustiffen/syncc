import SwiftUI
import Combine
import FirebaseFirestore


struct ChatView: View {
    @EnvironmentObject private var profileModel: ProfileModel
    @EnvironmentObject private var messagesManager: MessagesManager
    @StateObject private var matchMakingManager = MatchMakingManager()
    @State private var showPayWallView = false
    
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
    
    var body: some View {
        VStack {
            HStack {
                SyncBackButton()
                Spacer()
                Text("\(String(describing: usersFirstName))")
                    .foregroundStyle(.syncBlack)
            
                
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
                            
                            MessageBubbleView(message: message, isLastMessage: isLastMessage)
                                .id(index)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .onChange(of: messagesManager.messages.count) {
                        // Automatically scroll to the last message
                        withAnimation {
                            proxy.scrollTo(messagesManager.messages.count - 1)
                        }
                    }
                }
            }
            .animation(.easeIn, value: messagesManager.messages.count)
            .padding(.horizontal, 10)
            
            MessageFieldView(messages: $messagesManager.messages, showPayWallView: $showPayWallView, chatRoomId: chatRoomId, messageReceiver: messageReceiver)
                .frame(maxWidth: .infinity)
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
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
                messagesManager.makeMessagesSeen(
                    receivedMessages: filteredMessages,
                    chatRoomId: chatRoomId
                )
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
                    dismiss()
                    print("Unmatched user")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        case .block:
            matchMakingManager.unmatchUser(currentUserId: currentUserId, unmatchedUserId: messageReceiver.uid) { result in
                switch result {
                case .success:
                    dismiss()
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

