import EventKit
import MapKit
import SwiftUI


struct ParticipantsListView: View {
    @EnvironmentObject var profileModel: ProfileModel
    
    let participantIds: [String]
    @State private var participants: [DBUser] = []
    
    @State private var selectedUser: DBUser? = nil
    @State private var showInspectUser: Bool = false
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            titleView()
                .padding(.top, 10)
            
            Spacer()
            if !isLoading {
                ScrollView {
                    ForEach(participants, id: \.uid) { participant in
                        Button {
                            selectedUser = participant
                        } label: {
                            HStack {
                                if let image = participant.images?.first {
                                    ImageLoaderView(urlString: image.url)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                }
                                
                                Text(participant.name ?? "Unknown")
                                    .font(.headline)
                                    .foregroundStyle(.syncBlack)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.syncGrey)
                                    .font(.system(size: 14))
                            }
                            .padding(5)
                            .background(
                                Color.gray.opacity(0.1).clipShape(.rect(cornerRadius: 10))
                            )
                        }
                    }
                }
                .padding(.top, 10)
            } else {
                ProgressView("Loading Participants...")
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .sheet(item: $selectedUser) { user in
            ProfileCardView(user: user, isCurrentUser: profileModel.user == user, showButtons: false, showEditButton: false, likeAction: {}, dislikeAction: {})
        }
        .task {
            isLoading = true
            await loadParticipants()
            isLoading = false
        }
    }
    
    private func loadParticipants() async {
        var loadedUsers: [DBUser] = []
        
        for userId in participantIds {
            do {
                let user = try await DBUserManager.shared.getUser(uid: userId)
                loadedUsers.append(user)
            } catch {
                print("Failed to load user \(userId): \(error)")
            }
        }
        
        self.participants = loadedUsers
    }
    
    private func titleView() -> some View {
        HStack {
            Text("Participants")
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
