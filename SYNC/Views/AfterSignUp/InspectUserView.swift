import SwiftUI


struct InspectUserView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @Environment(\.dismiss) var dismiss
    
    var user: DBUser
    @StateObject var matchMakingManager = MatchMakingManager()
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 10)
            
            ProfileCardView(user: user, isCurrentUser: false) {
                Task {
                    try await likeAction()
                }
            } dislikeAction: {
                dislikeAction()
            }
        }
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func likeAction() async throws {
        var message: String = ""
        if !completeUsersModel.likesReceived.contains(where: { $0.userId == user.uid }) {
            message = "\(profileModel.user?.name ?? "") wants to sync up!"
        } else {
            message = "It's a match! Start a conversation with \(profileModel.user?.name ?? "") to sync up!"
        }

        matchMakingManager.sendLike(currentUserId: profileModel.user?.uid ?? "", likedUserId: user.uid, isSubscriptionActive: subscriptionModel.isSubscriptionActive) { result in
            switch result {
            case .success:
                NotificationManager.shared.sendSingularPushNotification(token: user.fcmToken ?? "", message: message, title: "Syncc") { result in
                    switch result {
                    case .success:
                        print("Success")
                        dismiss()
                    case .failure(let failure):
                        print("Failed to send notifcation: \(failure.localizedDescription)")
                    }
                }
                print("Like Sent")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func dislikeAction() {
        guard let currentUserId = profileModel.user?.uid else { return }
        Task {
            await matchMakingManager.dismissUser(currentUserId: currentUserId, dismissedUserId: user.uid)
            try await completeUsersModel.loadUsersForLikesReceived()
        }
        dismiss()
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton()
            Spacer()
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
}
