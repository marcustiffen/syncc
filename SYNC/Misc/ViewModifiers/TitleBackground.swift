import SwiftUI


struct TitleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.syncBlack)
            .h1Style()
    }
}
