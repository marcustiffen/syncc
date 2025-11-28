import SwiftUI
import FirebaseFirestore


class MySynccsViewModel: ObservableObject {
    @Published var matches: [DBUser] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var matchesListener: ListenerRegistration?
    
    func fetchMatches(for userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Set up real-time listener for matches
        matchesListener = db.collection("users")
            .document(userId)
            .collection("matches")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.matches = []
                    return
                }
                
                // Fetch full user details for each match
                self.fetchUserDetails(for: documents.map { $0.documentID })
            }
    }
    
    private func fetchUserDetails(for userIds: [String]) {
        guard !userIds.isEmpty else {
            matches = []
            return
        }
        
        let group = DispatchGroup()
        var fetchedUsers: [DBUser] = []
        
        for userId in userIds {
            group.enter()
            db.collection("users").document(userId).getDocument { snapshot, error in
                defer { group.leave() }
                
                if let data = snapshot?.data(),
                   let user = try? Firestore.Decoder().decode(DBUser.self, from: data) {
                    fetchedUsers.append(user)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.matches = fetchedUsers.sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
    }
    
    deinit {
        matchesListener?.remove()
    }
}

struct MySynccsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MySynccsViewModel()
    @EnvironmentObject var profileModel: ProfileModel
    
    @State private var selectedUser: DBUser? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            titleView()
                .padding(.horizontal, 10)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red.opacity(0.7))
                    Text("Error loading matches")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            } else if viewModel.matches.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No Synccs Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Start swiping to find your\nperfect workout partner!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.matches, id: \.uid) { match in
                            MatchCard(user: match)
                                .onTapGesture {
                                    selectedUser = match
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .sheet(item: $selectedUser) { user in
            ProfileCardView(user: user, isCurrentUser: profileModel.user == user, showButtons: false, showEditButton: false, likeAction: {}, dislikeAction: {})
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.fetchMatches(for: profileModel.user?.uid ?? "")
            
        }
    }
    
    private func titleView() -> some View {
        HStack {
            SyncBackButton {
                dismiss()
            }
            Text("My Synccs")
            Spacer()
            if !viewModel.matches.isEmpty {
                Text("\(viewModel.matches.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.syncGreen)
                    .clipShape(Capsule())
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}

struct MatchCard: View {
    let user: DBUser
    
    var usersFirstName: String {
        return user.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = user.images?.first {
                ImageLoaderView(urlString: image.url)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }

            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(usersFirstName)
                        .font(.h2)
                        .fontWeight(.bold)
                    
                    if let age = user.age {
                        Text("\(age)")
                            .font(.h2)
                            .foregroundStyle(.black)
                            .fontWeight(.semibold)
                    }
                }
                
                if let fitnessLevel = user.fitnessLevel {
                    Text(fitnessLevel)
                        .font(.bodyText)
                        .padding(.vertical, 3)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}
