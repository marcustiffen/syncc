import SwiftUI


struct SyncBackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left")
                .h1Style()
                .bold()
                .foregroundStyle(.syncBlack)
        }
    }
}
