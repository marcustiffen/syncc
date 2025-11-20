import SwiftUI


struct ChatRoomsView: View {
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var showPaywallView = false
    @State private var showCreateGroupChat = false


    var body: some View {
        VStack {
            headerSection
                .padding(.top, 50)
            
//            ScrollView(.vertical) {
//                ForEach(chatRoomsManager.chatRooms) { chatroom in
//                    ChatRoomRowView(
//                        chatroom: chatroom,
//                        currentUserId: profileModel.user?.uid ?? ""
//                    )
//                    .environmentObject(profileModel)
//                }
//            }
            
            ScrollView(.vertical) {
                ForEach(chatRoomsManager.chatRooms) { chatroom in
                    ChatRoomRowView(
                        chatroom: chatroom,
                        currentUserId: profileModel.user?.uid ?? ""
                    )
                    .environmentObject(profileModel)
                }
            }

            Spacer()
        }
        .overlay {
            if chatRoomsManager.chatRooms.isEmpty {
                VStack(alignment: .center) {
                    Image("sync_badgeDark")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    Text("No Synccs yet!")
                        .multilineTextAlignment(.center)
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
        }
        .sheet(isPresented: $showPaywallView, content: {
            PayWallView(isPaywallPresented: $showPaywallView)
        })
        .sheet(isPresented: $showCreateGroupChat, content: {
            NavigationStack {
                CreateGroupChatView(currentUserId: profileModel.user?.uid ?? "")
            }
        })
        .padding(.horizontal, 10)
        .background(
            Color.white
                .ignoresSafeArea()
        )
    }
    
    private var headerSection: some View {
        HStack {
            Text("Synccs")
                .bold()
            
            Spacer()
            
            Button {
                print("Create new chatroom")
                showCreateGroupChat = true
            } label: {
                Image(systemName: "plus.circle.fill")
            }

        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
