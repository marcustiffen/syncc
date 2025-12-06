//import SwiftUI
//
//
//struct DiscoverView: View {
//    @Environment(\.dismiss) var dismiss
//    
//    @EnvironmentObject var profileModel: ProfileModel
//    @EnvironmentObject var subscriptionModel: SubscriptionModel
//    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
//    
//    @StateObject private var viewModel = DiscoverViewModel()
//    @StateObject private var notificationManager = NotificationManager.shared
//    @Binding var showCreateOrSignInView: Bool
//    @Binding var loadingViewFinishedLoading: Bool
//    
//    @State private var selectedUser: DBUser?
//    @State private var showUserDetail = false
//    
//    // Grid layout configuration
//    private let columns = [
//        GridItem(.flexible(), spacing: 12),
//        GridItem(.flexible(), spacing: 12)
//    ]
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            if viewModel.isLoading {
//                Spacer()
//                LoadingView(
//                    isLoading: $viewModel.isLoading,
//                    loadingViewFinishedLoading: .constant(false),
//                    loadingMessage: .constant("")
//                )
//                Spacer()
//            } else if let errorMessage = viewModel.errorMessage {
//                errorMessageView(errorMessage)
//            } else if viewModel.userQueue.isEmpty {
//                emptyStateView()
//            } else {
//                usersGridView()
//            }
//        }
//        .sheet(isPresented: $viewModel.showPayWall) {
//            PayWallView(isPaywallPresented: $viewModel.showPayWall)
//        }
//        .sheet(
//            item: $selectedUser,
//            content: { user in
//                ProfileCardView(
//                    user: user,
//                    isCurrentUser: false,
//                    showButtons: true,
//                    showEditButton: false) {
//                        handleLike(user: user)
//                    } dislikeAction: {
//                        handleDislike(user: user)
//                    }
//
//        })
//        .onAppear {
//            guard let currentUser = profileModel.user else { return }
//            print("DiscoverView appeared - loading initial users")
//            viewModel.loadInitialUsers(for: currentUser)
//        }
//    }
//    
//    
//    private func usersGridView() -> some View {
//        ScrollView {
//            LazyVGrid(columns: columns, spacing: /*12*/20) {
//                ForEach(viewModel.userQueue, id: \.uid) { user in
//                    UserGridCard(user: user)
//                        .onTapGesture {
//                            selectedUser = user
//                            showUserDetail = true
//                        }
//                        .onAppear {
//                            // Load more when reaching the last few items
//                            if viewModel.shouldLoadMore(currentUser: user) {
//                                guard let currentUser = profileModel.user else { return }
//                                viewModel.fetchNextPage(for: currentUser, isInitialLoad: false)
//                            }
//                        }
//                }
//                
//                // Loading indicator at bottom
//                if viewModel.isPaginating {
//                    VStack {
//                        ProgressView()
//                            .padding()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .gridCellColumns(2)
//                }
//            }
////            .padding(.horizontal, 10)
//            .padding(.vertical, 16)
//        }
//        .refreshable {
//            guard let currentUser = profileModel.user else { return }
//            viewModel.refreshUsers(for: currentUser)
//        }
//    }
//    
//
//    
//    private func emptyStateView() -> some View {
//        VStack {
//            Spacer()
//            Image("syncc_badge_dark")
//                .resizable()
//                .frame(width: 200, height: 200)
//            Text("No users available! Update filters")
//                .multilineTextAlignment(.center)
//                .h2Style()
//                .foregroundStyle(.syncBlack)
//            Spacer()
//        }
//    }
//    
//    private func errorMessageView(_ message: String) -> some View {
//        VStack {
//            Spacer()
//            Image(systemName: "exclamationmark.triangle")
//                .font(.system(size: 60))
//                .foregroundColor(.red)
//            Text("Error")
//                .font(.h1)
//                .padding(.top)
//            Text(message)
//                .font(.bodyText)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding()
//            Button("Retry") {
//                guard let currentUser = profileModel.user else { return }
//                viewModel.loadInitialUsers(for: currentUser)
//            }
//            .buttonStyle(.borderedProminent)
//            Spacer()
//        }
//        .padding()
//    }
//    
//    
//    private func handleLike(user: DBUser) {
//        guard let currentUser = profileModel.user else { return }
//        
//        
//        viewModel.performLike(user: user, currentUser: currentUser, isSubscriptionActive: subscriptionModel.isSubscriptionActive) { result in
//            switch result {
//            case true:
//                // Send notification
//                if likesReceivedViewModel.likesReceived.contains(where: { $0.userId == user.uid }) {
//                    sendMatchNotification(to: user, from: currentUser)
//                } else {
//                    sendLikeNotification(to: user, from: currentUser)
//                }
//                print("Successfully liked user")
//            case false:
//                viewModel.showPayWall = true
//                print("Failed to like user")
//            }
//        }
//        
//
//        
////        dismiss()
//        
//        showUserDetail = false
//    }
//    
//    private func handleDislike(user: DBUser) {
//        guard let currentUser = profileModel.user else { return }
//        
//        viewModel.performDislike(
//            user: user,
//            currentUser: currentUser
//        )
//        
////        dismiss()
//        
//        showUserDetail = false
//    }
//    
//    // MARK: - Notifications
//    
//    private func sendLikeNotification(to user: DBUser, from currentUser: DBUser) {
//        guard let recipientToken = user.fcmToken else {
//            print("No FCM token found for user: \(user.uid)")
//            return
//        }
//        
//        let sendingFullName = currentUser.name ?? "Someone"
//        let sendingNameComponents = sendingFullName.split(separator: " ")
//        let sendingFirstName = String(sendingNameComponents.first ?? "")
//        
//        let title = "Syncc"
//        let message = "\(sendingFirstName) sent you a Syncc request!"
//        
//        notificationManager.sendSingularPushNotification(
//            token: recipientToken,
//            message: message,
//            title: title
//        ) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("Like notification sent successfully to \(user.name ?? "")")
//                case .failure(let error):
//                    print("Failed to send like notification: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    private func sendMatchNotification(to user: DBUser, from currentUser: DBUser) {
//        guard let recipientToken = user.fcmToken else {
//            print("No FCM token found for user: \(user.uid)")
//            return
//        }
//        
//        let sendingFullName = currentUser.name ?? "Someone"
//        let sendingNameComponents = sendingFullName.split(separator: " ")
//        let sendingFirstName = String(sendingNameComponents.first ?? "")
//        
//        let title = "Syncc"
//        let message = "It's a match! \(sendingFirstName) wants to Syncc up!"
//        
//        notificationManager.sendSingularPushNotification(
//            token: recipientToken,
//            message: message,
//            title: title
//        ) { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success:
//                    print("Match notification sent successfully to \(user.name ?? "user")")
//                case .failure(let error):
//                    print("Failed to send match notification: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//
//struct UserGridCard: View {
//    let user: DBUser
//    
//    var usersFirstName: String {
//        return user.name?.split(separator: " ").first.map(String.init) ?? ""
//    }
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .foregroundStyle(.syncWhite)
//                .shadow(radius: 2)
//            
//            VStack(alignment: .leading, spacing: 10) {
//                // Profile Image
//                if let image = user.images?.first {
//                    ImageLoaderView(urlString: image.url)
//                        .scaledToFill()
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .clipped()
//                } else {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .overlay(
//                            Image(systemName: "person.fill")
//                                .font(.system(size: 40))
//                                .foregroundColor(.gray)
//                        )
//                }
//                
//                // User Info
//                HStack(alignment: .top) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text(usersFirstName)
//                            .font(.h2)
//                            .bold()
//                            .foregroundStyle(.syncBlack)
//                            .lineLimit(1)
//                        
//                        Text(user.fitnessLevel ?? "Fitness Level")
//                            .bodyTextStyle()
//                            .foregroundStyle(.syncGrey)
//                            .lineLimit(1)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("\(user.age ?? 0)")
//                        .font(.h2)
//                        .foregroundStyle(.syncBlack)
//                        .bold()
//                }
//                .padding(.horizontal, 10)
//            }
//            .padding(.horizontal, 10)
//            .padding(.vertical, 10)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .background(Color.syncWhite)
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        .padding(.horizontal, 10)
//    }
//}
//
//struct UserDetailView: View {
//    let user: DBUser
//    let onLike: () -> Void
//    let onDislike: () -> Void
//    
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var profileModel: ProfileModel
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                ProfileCardView(
//                    user: user,
//                    isCurrentUser: false,
//                    showButtons: false,
//                    showEditButton: false,
//                    likeAction: {},
//                    dislikeAction: {}
//                )
//                .padding()
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Close") {
//                        dismiss()
//                    }
//                }
//            }
//            .safeAreaInset(edge: .bottom) {
//                HStack(spacing: 16) {
//                    Button {
//                        onDislike()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.title2)
//                            .foregroundColor(.red)
//                            .frame(width: 60, height: 60)
//                            .background(Color.white)
//                            .clipShape(Circle())
//                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//                    }
//                    
//                    Button {
//                        onLike()
//                    } label: {
//                        Image(systemName: "heart.fill")
//                            .font(.title2)
//                            .foregroundColor(.white)
//                            .frame(width: 60, height: 60)
//                            .background(Color.blue)
//                            .clipShape(Circle())
//                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
//                    }
//                }
//                .padding()
//                .background(Color(uiColor: .systemBackground))
//            }
//        }
//    }
//}



import SwiftUI

struct DiscoverView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
    
    @StateObject private var viewModel = DiscoverViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    @Binding var showCreateOrSignInView: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    @State private var selectedUser: DBUser?
    @State private var showUserDetail = false
    

    @FocusState private var isSearchFocused: Bool
    
    // Grid layout configuration
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {

            searchBarView()
            
            // Main content
            if viewModel.isLoading {
                Spacer()
                LoadingView(
                    isLoading: $viewModel.isLoading,
                    loadingViewFinishedLoading: .constant(false),
                    loadingMessage: .constant("")
                )
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                errorMessageView(errorMessage)
            } else if viewModel.filteredUserQueue.isEmpty {
                emptyStateView()
            } else {
                usersGridView()
            }
        }
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            dismissKeyboard()
        }
        .sheet(isPresented: $viewModel.showPayWall) {
            PayWallView(isPaywallPresented: $viewModel.showPayWall)
        }
        .sheet(
            item: $selectedUser,
            content: { user in
                ProfileCardView(
                    user: user,
                    isCurrentUser: false,
                    showButtons: true,
                    showEditButton: false) {
                        handleLike(user: user)
                    } dislikeAction: {
                        handleDislike(user: user)
                    }
        })
        .onAppear {
            guard let currentUser = profileModel.user else { return }
            print("DiscoverView appeared - loading initial users")
            viewModel.loadInitialUsers(for: currentUser)
        }
    }
    

    private func searchBarView() -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search by name...", text: $viewModel.searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            

            if !viewModel.searchText.isEmpty {
                Button {
                    performSearch()
                } label: {
                    Text("Search")
                        .font(.h2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.syncBlack)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.searchText.isEmpty)
    }
    
    /// Execute search and dismiss keyboard
    private func performSearch() {
        isSearchFocused = false
        viewModel.executeSearch()
    }
    
    /// Dismiss keyboard helper
    private func dismissKeyboard() {
        isSearchFocused = false
    }
    

    
    private func usersGridView() -> some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.filteredUserQueue, id: \.uid) { user in
                        UserGridCard(user: user)
                            .onTapGesture {
                                selectedUser = user
                                showUserDetail = true
                            }
                            .onAppear {
                                // Load more when reaching the last few items
                                if viewModel.shouldLoadMore(currentUser: user) {
                                    guard let currentUser = profileModel.user else { return }
                                    viewModel.fetchNextPage(for: currentUser, isInitialLoad: false)
                                }
                            }
                    }
                    
                    // Loading indicator at bottom
                    if viewModel.isPaginating {
                        VStack {
                            ProgressView()
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .gridCellColumns(2)
                    }
                }
                .padding(.vertical, 16)
            }
            .refreshable {
                guard let currentUser = profileModel.user else { return }
                viewModel.refreshUsers(for: currentUser)
            }
        }
    }
    
    private func emptyStateView() -> some View {
        VStack {
            Spacer()
            
            if !viewModel.activeSearchText.isEmpty {
                // Search returned no results
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                    .padding(.bottom, 16)
                
                Text("No Results Found")
                    .font(.h1)
                    .foregroundStyle(.syncBlack)
                    .padding(.bottom, 8)
                
                Text("No users found matching '\(viewModel.activeSearchText)'")
                    .font(.bodyText)
                    .foregroundStyle(.syncGrey)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 16)
                
                Button {
                    viewModel.clearSearch()
                } label: {
                    Text("Clear Search")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.syncBlack)
                        )
                }
            } else {
                // No users available (empty queue)
                Image("syncc_badge_dark")
                    .resizable()
                    .frame(width: 200, height: 200)
                
                Text("No users available! Update filters")
                    .multilineTextAlignment(.center)
                    .h2Style()
                    .foregroundStyle(.syncBlack)
            }
            
            Spacer()
        }
    }
    
    private func errorMessageView(_ message: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("Error")
                .font(.h1)
                .padding(.top)
            Text(message)
                .font(.bodyText)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                guard let currentUser = profileModel.user else { return }
                viewModel.loadInitialUsers(for: currentUser)
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Actions
    
    private func handleLike(user: DBUser) {
        guard let currentUser = profileModel.user else { return }
        
        viewModel.performLike(user: user, currentUser: currentUser, isSubscriptionActive: subscriptionModel.isSubscriptionActive) { result in
            switch result {
            case true:
                // Send notification
                if likesReceivedViewModel.likesReceived.contains(where: { $0.userId == user.uid }) {
                    sendMatchNotification(to: user, from: currentUser)
                } else {
                    sendLikeNotification(to: user, from: currentUser)
                }
                print("Successfully liked user")
            case false:
                viewModel.showPayWall = true
                print("Failed to like user")
            }
        }
        
        showUserDetail = false
    }
    
    private func handleDislike(user: DBUser) {
        guard let currentUser = profileModel.user else { return }
        
        viewModel.performDislike(
            user: user,
            currentUser: currentUser
        )
        
        showUserDetail = false
    }
    
    // MARK: - Notifications
    
    private func sendLikeNotification(to user: DBUser, from currentUser: DBUser) {
        guard let recipientToken = user.fcmToken else {
            print("No FCM token found for user: \(user.uid)")
            return
        }
        
        let sendingFullName = currentUser.name ?? "Someone"
        let sendingNameComponents = sendingFullName.split(separator: " ")
        let sendingFirstName = String(sendingNameComponents.first ?? "")
        
        let title = "Syncc"
        let message = "\(sendingFirstName) sent you a Syncc request!"
        
        notificationManager.sendSingularPushNotification(
            token: recipientToken,
            message: message,
            title: title
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Like notification sent successfully to \(user.name ?? "")")
                case .failure(let error):
                    print("Failed to send like notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func sendMatchNotification(to user: DBUser, from currentUser: DBUser) {
        guard let recipientToken = user.fcmToken else {
            print("No FCM token found for user: \(user.uid)")
            return
        }
        
        let sendingFullName = currentUser.name ?? "Someone"
        let sendingNameComponents = sendingFullName.split(separator: " ")
        let sendingFirstName = String(sendingNameComponents.first ?? "")
        
        let title = "Syncc"
        let message = "It's a match! \(sendingFirstName) wants to Syncc up!"
        
        notificationManager.sendSingularPushNotification(
            token: recipientToken,
            message: message,
            title: title
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Match notification sent successfully to \(user.name ?? "user")")
                case .failure(let error):
                    print("Failed to send match notification: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct UserGridCard: View {
    let user: DBUser
    
    var usersFirstName: String {
        return user.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.syncWhite)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 10) {
                // Profile Image
                if let image = user.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
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
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(usersFirstName)
                            .font(.h2)
                            .bold()
                            .foregroundStyle(.syncBlack)
                            .lineLimit(1)
                        
                        Text(user.fitnessLevel ?? "Fitness Level")
                            .bodyTextStyle()
                            .foregroundStyle(.syncGrey)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text("\(user.age ?? 0)")
                        .font(.h2)
                        .foregroundStyle(.syncBlack)
                        .bold()
                }
                .padding(.horizontal, 10)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.syncWhite)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 10)
    }
}
