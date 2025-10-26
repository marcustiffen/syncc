import SwiftUI


struct ChatRoomRowView: View {
    let chatroom: ChatRoom
    let currentUserId: String
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var profileModel: ProfileModel
    @StateObject private var messagesManager: MessagesManager

    // Custom initializer
    init(chatroom: ChatRoom, currentUserId: String) {
        self.chatroom = chatroom
        self.currentUserId = currentUserId
        self._messagesManager = StateObject(wrappedValue: MessagesManager(chatRoomId: chatroom.id))
    }

    var body: some View {
        // Get user from cache - no loading state needed!
        if let otherUser = chatRoomsManager.getOtherUser(in: chatroom, currentUserId: currentUserId) {
            NavigationLink {
                ChatView(messageReceiver: otherUser, chatRoomId: chatroom.id)
                    .environmentObject(messagesManager)
                    .environmentObject(profileModel)
            } label: {
                chatRoomRow(with: otherUser)
            }
        } else {
            HStack {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .syncBlack))
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 90)
        }
    }
    
    private func chatRoomRow(with otherUser: DBUser) -> some View {
        VStack {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .foregroundStyle(.syncGrey)
                .frame(height: 1)
            
            HStack(spacing: 15) {
                if let image = otherUser.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 75, height: 75)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(otherUser.name ?? "")
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(messagesManager.messages.last?.text ?? "")
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.syncBlack)
                        .bodyTextStyle()
                        .fontWeight(
                            profileModel.user?.uid == messagesManager.messages.last?.senderId
                                ? .regular
                                : (messagesManager.messages.last?.seen == true ? .regular : .semibold)
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 20)
            .frame(height: 75)
        }
        .frame(height: 90)
    }
}
