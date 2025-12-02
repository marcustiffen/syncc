import SwiftUI


struct SimpleMessageInputView: View {
    let chatRoomId: String
    let messageReceiver: DBUser
    let messagesManager: MessagesManager
    
    @EnvironmentObject private var profileModel: ProfileModel
    @State private var messageText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Fixed-height TextField
                HStack {
                    TextField("Message", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .focused($isFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                
                // Send Button
                if !messageText.isEmpty {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(Color.syncGreen)
                            .clipShape(Circle())
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: messageText.isEmpty)
        }
        .background(Color.white)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUser = profileModel.user else { return }
        
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        messagesManager.sendMessage(
            text: trimmedMessage,
            messageSender: currentUser,
            messageReceiver: messageReceiver
        )
        
        messageText = ""
        isFocused = true
    }
}
