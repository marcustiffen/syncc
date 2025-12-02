//import SwiftUI
//
//
//
//struct DiscoverView: View {
//    @EnvironmentObject var profileModel: ProfileModel
//    @EnvironmentObject var subscriptionModel: SubscriptionModel
//    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
//    
//    @StateObject private var viewModel = DiscoverViewModel()
//    @StateObject private var notificationManager = NotificationManager.shared
//    @Binding var showCreateOrSignInView: Bool
//    @Binding var loadingViewFinishedLoading: Bool
//    @State private var animationTrigger = UUID()
//    
//    // Add state to track if view has appeared
//    
//    var body: some View {
//        VStack {
//            
//            Spacer()
//            
//            if !viewModel.isLoading {
//                if !viewModel.cardQueue.isEmpty {
//                    ZStack {
//                        ForEach(Array(viewModel.cardQueue.prefix(3).enumerated()), id: \.element.uid) { idx, user in
//                            ProfileCardView(
//                                user: user,
//                                isCurrentUser: false,
//                                showButtons: true,
//                                showEditButton: false,
//                                likeAction: {
//                                    guard let currentUser = profileModel.user else { return }
//                                    viewModel.performCardAction(
//                                        isLike: true,
//                                        user: user,
//                                        currentUser: currentUser,
//                                        isSubscriptionActive: subscriptionModel.isSubscriptionActive
//                                    )
//                                    
//                                    // Send notification for like action
//                                    if likesReceivedViewModel.likesReceived.contains(where: { $0.userId == user.uid }) {
//                                        sendMatchNotification(to: user, from: currentUser)
//                                    } else {
//                                        sendLikeNotification(to: user, from: currentUser)
//                                    }
//                                },
//                                dislikeAction: {
//                                    guard let currentUser = profileModel.user else { return }
//                                    viewModel.performCardAction(
//                                        isLike: false,
//                                        user: user,
//                                        currentUser: currentUser,
//                                        isSubscriptionActive: subscriptionModel.isSubscriptionActive
//                                    )
//                                }
//                            )
//                            .scaleEffect(
//                                idx == 0 ? (viewModel.isAnimating ? 0.85 : 1.0) : 0.95
//                            )
//                            .zIndex(Double(3 - idx))
//                            .opacity(shouldAnimateCard(for: user.uid) ? 0 : 1)
//                            .offset(y: shouldAnimateCard(for: user.uid) ? 20 : 0)
//                            .scaleEffect(shouldAnimateCard(for: user.uid) ? 0.8 : 1.0)
//                            .animation(
//                                shouldAnimateCard(for: user.uid) ? .easeOut(duration: 0.6).delay(Double(idx) * 0.1) : nil,
//                                value: animationTrigger
//                            )
//                            .shadow(color: idx == 0 ? .black.opacity(0.1) : .clear, radius: idx == 0 ? 8 : 0, x: 0, y: 4)
//                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.cardQueue.count)
//                            .onAppear {
//                                if shouldAnimateCard(for: user.uid) {
//                                    // Mark this card as animated after animation completes
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(idx) * 0.1) {
//                                        viewModel.animatedCardIds.insert(user.uid)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                    .animation(.spring(response: 0.15, dampingFraction: 0.85), value: viewModel.isAnimating)
//                    .animation(.easeInOut(duration: 0.3), value: viewModel.cardQueue.count)
//                } else {
//                        VStack {
//                            Image("sync_badgeDark")
//                                .resizable()
//                                .frame(width: 200, height: 200)
//                            Text("No users available! Update filters")
//                                .multilineTextAlignment(.center)
//                                .h2Style()
//                                .foregroundStyle(.syncBlack)
//                        }
//                }
//                
//            } else {
//                LoadingView(isLoading: $viewModel.isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, loadingMessage: .constant(""))
//            }
//            
//            Spacer()
//        }
//        .sheet(isPresented: $viewModel.showPayWall) {
//            PayWallView(isPaywallPresented: $viewModel.showPayWall)
//        }
//        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
//            Button("OK") { viewModel.errorMessage = nil }
//        } message: {
//            if let error = viewModel.errorMessage {
//                Text(error)
//            }
//        }
//        .onAppear {
//            
//            guard let currentUser = profileModel.user else { return }
//
//            print("Empty card queue appeared - initial load")
//            viewModel.loadInitialUsers(for: currentUser)
//        }
//    }
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
//        let senderName = sendingFirstName
//        let title = "Syncc"
//        let message = "\(senderName) sent you a Syncc request!"
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
//        let senderName = sendingFirstName
//        let title = "Syncc"
//        let message = "It's a match! \(senderName) wants to Syncc up!"
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
//    
//    private func shouldAnimateCard(for cardId: String) -> Bool {
//        return viewModel.isFirstLoad &&
//               !viewModel.isBackgroundFetching &&
//               !viewModel.animatedCardIds.contains(cardId) &&
//               !viewModel.cardQueue.isEmpty
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
    
    // Grid layout configuration
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
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
            } else if viewModel.userQueue.isEmpty {
                emptyStateView()
            } else {
                usersGridView()
            }
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
    
    
    private func usersGridView() -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: /*12*/20) {
                ForEach(viewModel.userQueue, id: \.uid) { user in
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
//            .padding(.horizontal, 10)
            .padding(.vertical, 16)
        }
        .refreshable {
            guard let currentUser = profileModel.user else { return }
            viewModel.refreshUsers(for: currentUser)
        }
    }
    

    
    private func emptyStateView() -> some View {
        VStack {
            Spacer()
            Image("sync_badgeDark")
                .resizable()
                .frame(width: 200, height: 200)
            Text("No users available! Update filters")
                .multilineTextAlignment(.center)
                .h2Style()
                .foregroundStyle(.syncBlack)
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
        

        
//        dismiss()
        
        showUserDetail = false
    }
    
    private func handleDislike(user: DBUser) {
        guard let currentUser = profileModel.user else { return }
        
        viewModel.performDislike(
            user: user,
            currentUser: currentUser
        )
        
//        dismiss()
        
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

struct UserDetailView: View {
    let user: DBUser
    let onLike: () -> Void
    let onDislike: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ProfileCardView(
                    user: user,
                    isCurrentUser: false,
                    showButtons: false,
                    showEditButton: false,
                    likeAction: {},
                    dislikeAction: {}
                )
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 16) {
                    Button {
                        onDislike()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.red)
                            .frame(width: 60, height: 60)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Button {
                        onLike()
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
            }
        }
    }
}
