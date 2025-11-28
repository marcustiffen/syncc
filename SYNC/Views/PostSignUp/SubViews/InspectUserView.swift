import SwiftUI


struct InspectUserView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @Environment(\.dismiss) var dismiss
    
    
    var likeAction: () -> Void
    var dislikeAction: () -> Void
    var showHeader: Bool
    var showButtons: Bool
    
    var user: DBUser
    @StateObject var matchMakingManager = MatchMakingManager()
    
    var body: some View {
        VStack(spacing: 0) {
            if showHeader {
                headerSection
                    .padding(.top, 50)
            }
            
            ProfileCardView(user: user, isCurrentUser: false, showButtons: showButtons, showEditButton: false) {
                likeAction()
                dismiss()
            } dislikeAction: {
                dislikeAction()
                dismiss()
            }
        }
        .padding([.horizontal, .top], 10)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container)
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton { dismiss() }
            Spacer()
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
}
