struct GroupMembersView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    
    let chatRoom: ChatRoom
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(chatRoom.users, id: \.self) { userId in
                        if let user = chatRoomsManager.getUser(for: userId) {
                            memberRow(user: user)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton { dismiss() }
            Spacer()
            Text("Group Members")
                .h1Style()
            Spacer()
            Spacer().frame(width: 44) // Balance the back button
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
    
    private func memberRow(user: DBUser) -> some View {
        HStack(spacing: 15) {
            if let image = user.images?.first {
                ImageLoaderView(urlString: image.url)
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 50, height: 50)
            } else {
                Circle()
                    .fill(.syncGrey)
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(user.name ?? "Unknown")
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                
                if let bio = user.bio, !bio.isEmpty {
                    Text(bio)
                        .bodyTextStyle()
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}



