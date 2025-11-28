import SwiftUI


struct ChatInspectUserView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var showInspectView: Bool
    var user: DBUser
    
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 50)
            
            ProfileCardView(user: user, isCurrentUser: true, showButtons: false, showEditButton: false) {} dislikeAction: {}
        }
        .padding(.horizontal, 10)
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
