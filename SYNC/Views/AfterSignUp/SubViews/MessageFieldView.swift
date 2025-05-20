import SwiftUI


struct MessageFieldView: View {
    @EnvironmentObject private var profileModel: ProfileModel
    @EnvironmentObject private var subscriptionsModel: SubscriptionModel
    @EnvironmentObject private var messagesManager: MessagesManager
    
    
    @State private var message = ""
    @FocusState private var isFocused: Bool
    
    @Binding var messages: [Message]
    @Binding var showPayWallView: Bool

    
    let chatRoomId: String
    let messageReceiver: DBUser
    
    var body: some View {
        HStack(spacing: 10) {
            MessagingTextField(
                placeholder: Text("Message"),
                text: $message,
                onCommit: sendMessage
            )
            .textFieldStyle(PlainTextFieldStyle())
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .focused($isFocused)
            
            if !message.isEmpty {
                Button {
                    let user = profileModel.user!
                    let sendersMessages = messages.filter{ $0.senderId == user.uid }
                    let sendersMessagesCount = sendersMessages.count
                    
                    if subscriptionsModel.isSubscriptionActive == false && sendersMessagesCount > 15 {
                        showPayWallView = true
                    } else {
                        sendMessage()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.syncGreen)
                        .clipShape(Circle())
                }
                .transition(.scale)
            }
        }
        .padding()
        .background(Color.syncWhite)
        .animation(.default, value: message.isEmpty)
    }
    
    private func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        messagesManager.sendMessage(
            to: chatRoomId,
            text: message,
            messageSender: profileModel.user!,
            messageReceiver: messageReceiver
        )
        message = ""
        isFocused = true
    }
}

struct MessagingTextField: View {
    var placeholder: Text
    @Binding var text: String
    var onCommit: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .foregroundColor(.gray)
            }
            
            TextField("", text: $text, onCommit: onCommit)
                .h2Style()
        }
    }
}
