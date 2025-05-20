import Foundation
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


struct TitleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.syncBlack)
            .h1Style()
    }
}



extension View {
    func withDefaultButtonFormatting() -> some View {
        modifier(RectangleBackground())
    }
    
    func onBoardingBackground() -> some View {
        modifier(OnBoardingBackground())
    }
    
    func titleModifiers() -> some View {
        modifier(TitleBackground())
    }
}



extension Font {
    static let h1 = Font.custom("Poppins-Bold", size: 30)
    static let h2 = Font.custom("Poppins-Regular", size: 16)
    static let bodyText = Font.custom("Poppins-Regular", size: 14)
}

extension View {
    func h1Style() -> some View {
        self.font(.custom("Poppins-Bold", size: 30))
    }
    
    func h2Style() -> some View {
        self.font(.custom("Poppins-Regular", size: 16))
            .tracking(2)
    }
    
    func bodyTextStyle() -> some View {
        self.font(.custom("Poppins-Regular", size: 14))
    }
}

