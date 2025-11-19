import SwiftUI





struct DiscoverView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
    
    @StateObject private var viewModel = DiscoverViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    @Binding var showCreateOrSignInView: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @Binding var isLoading: Bool
    @State private var animationTrigger = UUID()
    
    // Add state to track if view has appeared
    @State private var hasAppeared = false
    
    var body: some View {
        VStack {
//            filterView()
//                .padding(.top, 50)
            
            Spacer()
            
            ZStack {
                ForEach(Array(viewModel.cardQueue.prefix(3).enumerated()), id: \.element.uid) { idx, user in
                    ProfileCardView(
                        user: user,
                        isCurrentUser: false,
                        showEditButton: false,
                        likeAction: {
                            guard let currentUser = profileModel.user else { return }
                            viewModel.performCardAction(
                                isLike: true,
                                user: user,
                                currentUser: currentUser,
                                isSubscriptionActive: subscriptionModel.isSubscriptionActive
                            )
                            
                            // Send notification for like action
                            if likesReceivedViewModel.likesReceived.contains(where: { $0.userId == user.uid }) {
                                sendMatchNotification(to: user, from: currentUser)
                            } else {
                                sendLikeNotification(to: user, from: currentUser)
                            }
                        },
                        dislikeAction: {
                            guard let currentUser = profileModel.user else { return }
                            viewModel.performCardAction(
                                isLike: false,
                                user: user,
                                currentUser: currentUser,
                                isSubscriptionActive: subscriptionModel.isSubscriptionActive
                            )
                        }
                    )
                    .scaleEffect(
                        idx == 0 ? (viewModel.isAnimating ? 0.85 : 1.0) : 0.95
                    )
                    .zIndex(Double(3 - idx))
                    .opacity(shouldAnimateCard(for: user.uid) ? 0 : 1)
                    .offset(y: shouldAnimateCard(for: user.uid) ? 20 : 0)
                    .scaleEffect(shouldAnimateCard(for: user.uid) ? 0.8 : 1.0)
                    .animation(
                        shouldAnimateCard(for: user.uid) ? .easeOut(duration: 0.6).delay(Double(idx) * 0.1) : nil,
                        value: animationTrigger
                    )
                    .shadow(color: idx == 0 ? .black.opacity(0.1) : .clear, radius: idx == 0 ? 8 : 0, x: 0, y: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.cardQueue.count)
                    .onAppear {
                        if shouldAnimateCard(for: user.uid) {
                            // Mark this card as animated after animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(idx) * 0.1) {
                                viewModel.animatedCardIds.insert(user.uid)
                            }
                        }
                    }
                }
            }
            .animation(.spring(response: 0.15, dampingFraction: 0.85), value: viewModel.isAnimating)
            .animation(.easeInOut(duration: 0.3), value: viewModel.cardQueue.count)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .sheet(isPresented: $viewModel.showPayWall) {
            PayWallView(isPaywallPresented: $viewModel.showPayWall)
        }
        .overlay {
            if viewModel.cardQueue.isEmpty && !viewModel.isLoading {
                VStack {
                    Image("sync_badgeDark")
                        .resizable()
                        .frame(width: 200, height: 200)
                    Text("No users available! Update filters")
                        .multilineTextAlignment(.center)
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            guard let currentUser = profileModel.user else { return }

            print("Empty card queue appeared - initial load")
            viewModel.loadInitialUsers(for: currentUser)
        }
    }
    
    private func sendLikeNotification(to user: DBUser, from currentUser: DBUser) {
        guard let recipientToken = user.fcmToken else {
            print("No FCM token found for user: \(user.uid)")
            return
        }
        
        let sendingFullName = currentUser.name ?? "Someone"
        let sendingNameComponents = sendingFullName.split(separator: " ")
        let sendingFirstName = String(sendingNameComponents.first ?? "")
        
        let senderName = sendingFirstName
        let title = "Syncc"
        let message = "\(senderName) sent you a Syncc request!"
        
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
        
        let senderName = sendingFirstName
        let title = "Syncc"
        let message = "It's a match! \(senderName) wants to Syncc up!"
        
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
    
    private func shouldAnimateCard(for cardId: String) -> Bool {
        return viewModel.isFirstLoad &&
               !viewModel.isBackgroundFetching &&
               !viewModel.animatedCardIds.contains(cardId) &&
               !viewModel.cardQueue.isEmpty
    }
}
