import SwiftUI

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
    
    func withDefaultButtonFormatting() -> some View {
        modifier(RectangleBackground())
    }
    
    func onBoardingBackground() -> some View {
        modifier(OnBoardingBackground())
    }
    
    func titleModifiers() -> some View {
        modifier(TitleBackground())
    }
    
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}
