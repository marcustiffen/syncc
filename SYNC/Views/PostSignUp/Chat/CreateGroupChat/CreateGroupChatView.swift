//import SwiftUI
//import FirebaseFirestore
//
//class CreateGroupChatViewModel: ObservableObject {
//    
//    @Published var myMatches: [DBUser] = []
//    @Published var groupChatName: String = ""
//    @Published var selectedMembers: Set<String> = []
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//    
//    private let db = Firestore.firestore()
//    private let currentUserId: String
//    
//    init(currentUserId: String) {
//        self.currentUserId = currentUserId
//    }
//    
//    func getMyMatches() {
//        isLoading = true
//        errorMessage = nil
//        
//        db.collection("users")
//            .document(currentUserId)
//            .collection("matches")
//            .getDocuments { [weak self] snapshot, error in
//                guard let self = self else { return }
//                
//                if let error = error {
//                    self.errorMessage = "Failed to load matches: \(error.localizedDescription)"
//                    self.isLoading = false
//                    return
//                }
//                
//                guard let documents = snapshot?.documents else {
//                    self.isLoading = false
//                    return
//                }
//                
//                let matchIds = documents.map { $0.documentID }
//                
//                if matchIds.isEmpty {
//                    self.myMatches = []
//                    self.isLoading = false
//                    return
//                }
//                
//                // Fetch user details for each match
//                self.fetchUserDetails(userIds: matchIds)
//            }
//    }
//    
//    private func fetchUserDetails(userIds: [String]) {
//        let group = DispatchGroup()
//        var fetchedUsers: [DBUser] = []
//        
//        for userId in userIds {
//            group.enter()
//            db.collection("users").document(userId).getDocument { snapshot, error in
//                defer { group.leave() }
//                
//                if let snapshot = snapshot,
//                   let user = try? snapshot.data(as: DBUser.self) {
//                    fetchedUsers.append(user)
//                }
//            }
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            self?.myMatches = fetchedUsers.sorted { $0.name ?? "" < $1.name ?? "" }
//            self?.isLoading = false
//        }
//    }
//    
//    func toggleMemberSelection(userId: String) {
//        if selectedMembers.contains(userId) {
//            selectedMembers.remove(userId)
//        } else {
//            selectedMembers.insert(userId)
//        }
//    }
//    
//    func createGroupChat(completion: @escaping (Result<String, Error>) -> Void) {
//        guard !groupChatName.trimmingCharacters(in: .whitespaces).isEmpty else {
//            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Group name is required"])))
//            return
//        }
//        
//        guard selectedMembers.count >= 1 else {
//            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least one member"])))
//            return
//        }
//        
//        // Include current user in the group
//        var allUsers = Array(selectedMembers)
//        allUsers.append(currentUserId)
//        
//        let groupChat = GroupChatRoom(
//            name: groupChatName,
//            users: allUsers,
//            createdAt: Date()
//        )
//        
//        do {
//            let docRef = db.collection("chatRooms").document()
//            var groupChatWithId = groupChat
//            groupChatWithId.id = docRef.documentID
//            
//            try docRef.setData(from: groupChatWithId) { error in
//                if let error = error {
//                    completion(.failure(error))
//                } else {
//                    completion(.success(docRef.documentID))
//                }
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//}
//
//struct CreateGroupChatView: View {
//    
//    @StateObject private var viewModel: CreateGroupChatViewModel
//    @Environment(\.dismiss) private var dismiss
//    
//    init(currentUserId: String) {
//        _viewModel = StateObject(wrappedValue: CreateGroupChatViewModel(currentUserId: currentUserId))
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                headerSection
//                    .padding(.top, 50)
//                
//                CustomOnBoardingTextField(
//                    placeholder: "Group Chat Name",
//                    text: $viewModel.groupChatName
//                )
//                .padding(.horizontal)
//                
//                ForEach(viewModel.selectedMembers)
//                
//                
//                if viewModel.isLoading {
//                    ProgressView()
//                        .padding()
//                } else if let error = viewModel.errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .font(.caption)
//                        .padding()
//                } else {
//                    NavigationLink {
//                        AddMembersView(viewModel: viewModel)
//                    } label: {
//                        HStack {
//                            Text("Add Members")
//                            if !viewModel.selectedMembers.isEmpty {
//                                Text("(\(viewModel.selectedMembers.count))")
//                                    .foregroundColor(.syncBlack.opacity(0.7))
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.horizontal, 20)
//                        .foregroundStyle(.syncBlack)
//                        .h2Style()
//                        .padding(.vertical, 10)
//                        .background(
//                            Rectangle()
//                                .clipShape(.rect(cornerRadius: 10))
//                                .foregroundStyle(.syncGreen)
//                        )
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal, 10)
//            .onAppear {
//                viewModel.getMyMatches()
//            }
//        }
//    }
//    
//    private var headerSection: some View {
//        HStack {
//            Text("Create a group chat")
//                .bold()
//            
//            Spacer()
//        }
//        .h1Style()
//        .foregroundStyle(.syncBlack)
//        .padding(.horizontal)
//    }
//}
//
//
//
//struct AddMembersView: View {
//    
//    @ObservedObject var viewModel: CreateGroupChatViewModel
//    @Environment(\.dismiss) private var dismiss
//    @State private var isCreating = false
//    @State private var showSuccessAlert = false
//    @State private var showErrorAlert = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            headerSection
//                .padding(.top, 25)
//            
//            if viewModel.myMatches.isEmpty {
//                VStack(spacing: 20) {
//                    Image(systemName: "person.2.slash")
//                        .font(.system(size: 60))
//                        .foregroundColor(.gray)
//                    Text("No matches yet")
//                        .h2Style()
//                        .foregroundColor(.gray)
//                    Text("Start swiping to find your workout buddies!")
//                        .bodyTextStyle()
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                }
//            } else {
//                ScrollView {
//                    LazyVStack(spacing: 12) {
//                        ForEach(viewModel.myMatches, id: \.uid) { match in
//                            MatchRow(
//                                user: match,
//                                isSelected: viewModel.selectedMembers.contains(match.uid)
//                            ) {
//                                viewModel.toggleMemberSelection(userId: match.uid)
//                            }
//                        }
//                    }
//                }
//                .padding(.top, 25)
//                
//                // Create Button
//                Button(action: createGroup) {
//                    HStack {
//                        if isCreating {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .syncBlack))
//                        } else {
//                            Text("Create Group Chat")
//                                .font(.h2)
//                                .bold()
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(
//                                viewModel.selectedMembers.count < 2 ? Color.gray : Color.syncGreen
//                            )
//                    )
//                    .foregroundColor(.syncBlack)
//                }
//                .disabled(viewModel.selectedMembers.isEmpty || isCreating || viewModel.selectedMembers.count < 2)
//            }
//        }
//        .padding(.horizontal, 10)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarTitleDisplayMode(.inline)
//        .alert("Success", isPresented: $showSuccessAlert) {
//            Button("OK") {
//                dismiss()
//            }
//        } message: {
//            Text(alertMessage)
//        }
//        .alert("Error", isPresented: $showErrorAlert) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(alertMessage)
//        }
//    }
//    
//    private func createGroup() {
//        isCreating = true
//        
//        viewModel.createGroupChat { result in
//            isCreating = false
//            
//            switch result {
//            case .success:
//                alertMessage = "Group chat created successfully!"
//                showSuccessAlert = true
//            case .failure(let error):
//                alertMessage = error.localizedDescription
//                showErrorAlert = true
//            }
//        }
//    }
//    
//    
//    private var headerSection: some View {
//        HStack {
//            SyncBackButton {
//                dismiss()
//            }
//            Spacer()
//            Text("Add Members")
//                .bold()
//            Spacer()
//        }
//        .h2Style()
//        .bold()
//        .foregroundStyle(.syncBlack)
//    }
//}
//
//struct MatchRow: View {
//    let user: DBUser
//    let isSelected: Bool
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            HStack(spacing: 12) {
//                // Profile Image
//                if let image = user.images?.first {
//                    ImageLoaderView(urlString: image.url)
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 50, height: 50)
//                        .clipShape(Circle())
//                        .overlay(
//                            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 4)
//                        )
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.1))
//                        .frame(width: 50, height: 50)
//                }
//                
//                // User Info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(user.name ?? "Unknown")
//                        .font(.h2)
//                        .bold()
//                        .foregroundColor(.syncBlack)
//                    
//                    if let age = user.age {
//                        Text("\(age) years old")
//                            .bodyTextStyle()
//                            .foregroundColor(.gray)
//                    }
//                }
//                
//                Spacer()
//                
//                // Selection Indicator
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .font(.title2)
//                    .foregroundColor(isSelected ? .syncGreen : .gray.opacity(0.5))
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(isSelected ? Color.syncGreen.opacity(0.1) : Color.white)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(isSelected ? Color.syncGreen : Color.gray.opacity(0.2), lineWidth: 2)
//                    )
//            )
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}


import SwiftUI
import FirebaseFirestore

class CreateGroupChatViewModel: ObservableObject {
    
    @Published var myMatches: [DBUser] = []
    @Published var groupChatName: String = ""
    @Published var selectedMembers: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let currentUserId: String
    
    init(currentUserId: String) {
        self.currentUserId = currentUserId
    }
    
    func getMyMatches() {
        isLoading = true
        errorMessage = nil
        
        db.collection("users")
            .document(currentUserId)
            .collection("matches")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to load matches: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                let matchIds = documents.map { $0.documentID }
                
                if matchIds.isEmpty {
                    self.myMatches = []
                    self.isLoading = false
                    return
                }
                
                // Fetch user details for each match
                self.fetchUserDetails(userIds: matchIds)
            }
    }
    
    private func fetchUserDetails(userIds: [String]) {
        let group = DispatchGroup()
        var fetchedUsers: [DBUser] = []
        
        for userId in userIds {
            group.enter()
            db.collection("users").document(userId).getDocument { snapshot, error in
                defer { group.leave() }
                
                if let snapshot = snapshot,
                   let user = try? snapshot.data(as: DBUser.self) {
                    fetchedUsers.append(user)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.myMatches = fetchedUsers.sorted { $0.name ?? "" < $1.name ?? "" }
            self?.isLoading = false
        }
    }
    
    func toggleMemberSelection(userId: String) {
        if selectedMembers.contains(userId) {
            selectedMembers.remove(userId)
        } else {
            selectedMembers.insert(userId)
        }
    }
    
    func createGroupChat(completion: @escaping (Result<String, Error>) -> Void) {
        guard !groupChatName.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Group name is required"])))
            return
        }
        
        guard selectedMembers.count >= 2 else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Select at least two members"])))
            return
        }
        
        // Include current user in the group
        var allUsers = Array(selectedMembers)
        allUsers.append(currentUserId)
        
        let groupChat = /*Group*/ChatRoom(
            name: groupChatName,
            users: allUsers,
            createdAt: Date()
        )
        
        do {
            let docRef = db.collection("chatRooms").document()
            var groupChatWithId = groupChat
            groupChatWithId.id = docRef.documentID
            
            try docRef.setData(from: groupChatWithId) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(docRef.documentID))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

struct CreateGroupChatView: View {
    
    @StateObject private var viewModel: CreateGroupChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isCreating = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    
    init(currentUserId: String) {
        _viewModel = StateObject(wrappedValue: CreateGroupChatViewModel(currentUserId: currentUserId))
    }
    
    var body: some View {
            VStack(spacing: 20) {
                headerSection
                    .padding(.top, 50)
                
                CustomOnBoardingTextField(
                    placeholder: "Group Chat Name",
                    text: $viewModel.groupChatName
                )
                .padding(.horizontal)
                
                // Display selected members
                if !viewModel.selectedMembers.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Members (\(viewModel.selectedMembers.count))")
                            .font(.h2)
                            .bold()
                            .foregroundColor(.syncBlack)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(selectedMemberUsers, id: \.uid) { user in
                                    SelectedMemberRow(user: user) {
                                        viewModel.toggleMemberSelection(userId: user.uid)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                } else {
                    NavigationLink {
                        AddMembersView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Text("Add Members")
                            if !viewModel.selectedMembers.isEmpty {
                                Text("(\(viewModel.selectedMembers.count))")
                                    .foregroundColor(.syncBlack.opacity(0.7))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                
                Spacer()
                
                // Create Group Chat Button at bottom
                Button(action: createGroup) {
                    HStack {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .syncBlack))
                        } else {
                            Text("Create Group Chat")
                                .font(.h2)
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(canCreateGroup ? Color.syncGreen : Color.gray)
                    )
                    .foregroundColor(.syncBlack)
                }
                .disabled(!canCreateGroup || isCreating)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 10)
            .onAppear {
                viewModel.getMyMatches()
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(alertMessage)
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        
    }
    
    private var selectedMemberUsers: [DBUser] {
        viewModel.myMatches.filter { viewModel.selectedMembers.contains($0.uid) }
    }
    
    private var canCreateGroup: Bool {
        !viewModel.groupChatName.trimmingCharacters(in: .whitespaces).isEmpty &&
        viewModel.selectedMembers.count >= 2
    }
    
    private func createGroup() {
        isCreating = true
        
        viewModel.createGroupChat { result in
            isCreating = false
            
            switch result {
            case .success:
                alertMessage = "Group chat created successfully!"
                showSuccessAlert = true
            case .failure(let error):
                alertMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Create a group chat")
                .bold()
            
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
        .padding(.horizontal)
    }
}



struct AddMembersView: View {
    
    @ObservedObject var viewModel: CreateGroupChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 25)
            
            if viewModel.myMatches.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No matches yet")
                        .h2Style()
                        .foregroundColor(.gray)
                    Text("Start swiping to find your workout buddies!")
                        .bodyTextStyle()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.myMatches, id: \.uid) { match in
                            MatchRow(
                                user: match,
                                isSelected: viewModel.selectedMembers.contains(match.uid)
                            ) {
                                viewModel.toggleMemberSelection(userId: match.uid)
                            }
                        }
                    }
                }
                .padding(.top, 25)
            }
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    private var headerSection: some View {
        HStack {
            SyncBackButton {
                dismiss()
            }
            Spacer()
            Text("Add Members")
                .bold()
            Spacer()
        }
        .h2Style()
        .bold()
        .foregroundStyle(.syncBlack)
    }
}

struct MatchRow: View {
    let user: DBUser
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile Image
                if let image = user.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name ?? "Unknown")
                        .font(.h2)
                        .bold()
                        .foregroundColor(.syncBlack)
                    
                    if let age = user.age {
                        Text("\(age) years old")
                            .bodyTextStyle()
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .syncGreen : .gray.opacity(0.5))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.syncGreen.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.syncGreen : Color.gray.opacity(0.2), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectedMemberRow: View {
    let user: DBUser
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            if let image = user.images?.first {
                ImageLoaderView(urlString: image.url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
            }
            
            // User Info
            Text(user.name ?? "Unknown")
                .bodyTextStyle()
                .foregroundColor(.syncBlack)
            
            Spacer()
            
            // Remove Button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.syncGreen.opacity(0.1))
        )
        .padding(.horizontal)
    }
}
