import SwiftUI



struct OnBoardingBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.white
                    .ignoresSafeArea()
            )
    }
}
