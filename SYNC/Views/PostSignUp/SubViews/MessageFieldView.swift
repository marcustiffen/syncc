import SwiftUI




struct MessageFieldView: View {
    @Binding var messages: [Message]
//    @Binding var showPayWallView: Bool
    let chatRoomId: String
    let messageReceiver: DBUser
    let messagesManager: MessagesManager // Accept the specific MessagesManager instance
    
    @EnvironmentObject private var profileModel: ProfileModel
    @EnvironmentObject private var subscriptionsModel: SubscriptionModel
    @State private var messageText = ""
    
    @FocusState private var isFocused: Bool
    

    var body: some View {
        HStack(spacing: 10) {
            MessagingTextField(
                placeholder: Text("Message"),
                text: $messageText,
                onCommit: sendMessage
            )
            .textFieldStyle(PlainTextFieldStyle())
            .padding(12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .focused($isFocused)
            
            if !messageText.isEmpty {
                Button {
//                    let user = profileModel.user!
//                    let sendersMessages = messages.filter{ $0.senderId == user.uid }
//                    let sendersMessagesCount = sendersMessages.count
                    
//                    if subscriptionsModel.isSubscriptionActive == false && sendersMessagesCount > 15 {
//                        showPayWallView = true
//                    } else {
                        sendMessage()
//                    }
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
        .animation(.default, value: messageText.isEmpty)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUser = profileModel.user else { return }
        
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Use the specific MessagesManager instance to send the message
        messagesManager.sendMessage(
            text: trimmedMessage,
            messageSender: currentUser,
            messageReceiver: messageReceiver
        )
        
        messageText = ""
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
                .bodyTextStyle()
        }
    }
}
