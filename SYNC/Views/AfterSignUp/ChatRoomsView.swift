import SwiftUI

struct ChatRoomsView: View {
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var messagesManager: MessagesManager
    
    @State private var showPaywallView = false

    var body: some View {
        VStack {
            headerSection
                .padding(.top, 50)
            
            ScrollView(.vertical) {
                ForEach(chatRoomsManager.chatRooms) { chatroom in
                    ChatRoomRowView(chatroom: chatroom, currentUserId: profileModel.user?.uid ?? "")
                        .onAppear {
                            messagesManager.addListenerForChatRoom(chatRoomId: chatroom.id)
                        }
                        .padding(.vertical, 20)
                }
            }

            Spacer()
        }
        .overlay {
            if chatRoomsManager.chatRooms.isEmpty == true {
                VStack(alignment: .center) {
                    Image("sync_badgeDark")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    Text("No synccs yet!")
                        .multilineTextAlignment(.center)
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
        }
        .sheet(isPresented: $showPaywallView, content: {
            PayWallView(isPaywallPresented: $showPaywallView)
        })
        .padding(.horizontal, 10)
        .background(
            Color.white
                .ignoresSafeArea()
        )
    }
    
    private var headerSection: some View {
        HStack {
            Text("synccs")
                .bold()
            
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}


struct ChatRoomRowView: View {
    let chatroom: ChatRoom
    let currentUserId: String
    @State private var otherUser: DBUser?
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var profileModel: ProfileModel
    
    @State private var lastMessageText = ""

    var body: some View {
        mainView
            .task {
                await fetchOtherUser()
            }
    }
    

    private var mainView: some View {
        guard let otherUser = otherUser else {
            return AnyView(ProgressView("Loading..."))
        }

        return AnyView(
            NavigationLink {
                ChatView(messageReceiver: otherUser, chatRoomId: chatroom.id)
                    .environmentObject(messagesManager)
            } label: {
                VStack {
                    Rectangle()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .foregroundStyle(.syncGrey)
                        .frame(height: 1)
                    
                    HStack(spacing: 15) {
//                        if let image = otherUser.imageUrls?.first {
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
                                .truncationMode(.tail) // Ensures long names are cut off cleanly

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
                        .frame(maxWidth: .infinity, alignment: .leading) // Allow text to expand properly
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 75)
                }
                .frame(height: 90)
            }
        )
    }

    private func fetchOtherUser() async {
        let otherUsers = chatroom.users.filter { $0 != currentUserId }
        do {
            if let otherUserId = otherUsers.first {
                let user = try await DBUserManager.shared.getUser(uid: otherUserId)
                otherUser = user
            } else {
                print("No other user found in chatroom.")
            }
        } catch {
            print("Error getting user in ChatRoomRowView: \(error)")
        }
    }
}

