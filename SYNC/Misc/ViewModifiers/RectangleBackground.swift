import SwiftUI



struct RectangleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerRadius: 10))
            .frame(width: 350, height: 65)
            .padding()
            .padding(.vertical, 10)
    }
}
