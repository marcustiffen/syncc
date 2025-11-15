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
        if let otherUser = chatRoomsManager.getOtherUser(in: chatroom, currentUserId: currentUserId) {
            NavigationLink {
                ChatView(messageReceiver: otherUser, chatRoomId: chatroom.id)
                    .environmentObject(messagesManager)
                    .environmentObject(profileModel)
            } label: {
                if chatroom.users.count == 2 {
                    chatRoomRow(with: otherUser)
                } else {
                    groupChatRoomRow(with: chatroom.users, groupChat: chatroom)
                }
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
                        .frame(width: 60, height: 60)
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
    
    //    private func groupChatRoomRow(with users: [String], groupChat: ChatRoom) -> some View {
    //        VStack {
    //            Rectangle()
    //                .clipShape(RoundedRectangle(cornerRadius: 5))
    //                .foregroundStyle(.syncGrey)
    //                .frame(height: 1)
    //
    //            HStack(spacing: 15) {
    //                // Overlapping circles container
    //                ZStack(alignment: .topLeading) {
    //                    // Bottom right circle
    //                    if users.count > 1, let secondUser = chatRoomsManager.getUser(for: users[1]) {
    //                        if let image = secondUser.images?.first {
    //                            ImageLoaderView(urlString: image.url)
    //                                .scaledToFill()
    //                                .clipShape(Circle())
    //                                .frame(width: 50, height: 50)
    //                                .overlay(
    //                                    Circle()
    //                                        .stroke(.white, lineWidth: 2)
    //                                )
    //                                .offset(x: 10, y: 10)
    //                        } else {
    //                            Circle()
    //                                .fill(.syncGrey)
    //                                .frame(width: 50, height: 50)
    //                                .overlay(
    //                                    Circle()
    //                                        .stroke(.white, lineWidth: 2)
    //                                )
    //                                .offset(x: 25, y: 25)
    //                        }
    //                    }
    //
    //                    // Top left circle (on top)
    //                    if let firstUser = chatRoomsManager.getUser(for: users[0]) {
    //                        if let image = firstUser.images?.first {
    //                            ImageLoaderView(urlString: image.url)
    //                                .scaledToFill()
    //                                .clipShape(Circle())
    //                                .frame(width: 50, height: 50)
    //                                .overlay(
    //                                    Circle()
    //                                        .stroke(.white, lineWidth: 2)
    //                                )
    //                        } else {
    //                            Circle()
    //                                .fill(.syncGrey)
    //                                .frame(width: 50, height: 50)
    //                                .overlay(
    //                                    Circle()
    //                                        .stroke(.white, lineWidth: 2)
    //                                )
    //                        }
    //                    }
    //                }
    //                .frame(width: 75, height: 75)
    //
    //                VStack(alignment: .leading, spacing: 5) {
    //                    // Group chat name (you might want to add a name property to ChatRoom)
    //                    Text(groupChat.name)
    //                        .foregroundStyle(.syncBlack)
    //                        .h2Style()
    //                        .fontWeight(.bold)
    //                        .lineLimit(1)
    //                        .truncationMode(.tail)
    //
    //                    Text(messagesManager.messages.last?.text ?? "")
    //                        .lineLimit(1)
    //                        .multilineTextAlignment(.leading)
    //                        .foregroundStyle(.syncBlack)
    //                        .bodyTextStyle()
    //                        .fontWeight(
    //                            profileModel.user?.uid == messagesManager.messages.last?.senderId
    //                                ? .regular
    //                                : (messagesManager.messages.last?.seen == true ? .regular : .semibold)
    //                        )
    //                }
    //                .frame(maxWidth: .infinity, alignment: .leading)
    //            }
    //            .padding(.horizontal, 20)
    //            .frame(height: 75)
    //        }
    //        .frame(height: 90)
    //    }
    
    
    private func groupChatRoomRow(with users: [String], groupChat: ChatRoom) -> some View {
        VStack {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .foregroundStyle(.syncGrey)
                .frame(height: 1)
            
            HStack(spacing: 15) {
                // Overlapping circles container - FIXED
                ZStack(alignment: .topLeading) {
                    // Bottom right circle
                    if users.count > 1, let secondUser = chatRoomsManager.getUser(for: users[1]) {
                        if let image = secondUser.images?.first {
                            ImageLoaderView(urlString: image.url)
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                                .offset(x: 20, y: 20)
                        } else {
                            Circle()
                                .fill(.syncGrey)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                                .offset(x: 20, y: 20)
                        }
                    }
                    
                    // Top left circle (on top) - FIXED
                    if let firstUser = chatRoomsManager.getUser(for: users[0]) {
                        if let image = firstUser.images?.first {
                            ImageLoaderView(urlString: image.url)
                                .scaledToFill()
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                        } else {
                            Circle()
                                .fill(.syncGrey)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                        }
                    }
                }
                .frame(width: 60, height: 60) // Match single chat avatar size
                .offset(x: -10, y: -10)

                
                VStack(alignment: .leading, spacing: 5) {
                    Text(groupChat.name)
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
