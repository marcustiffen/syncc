
import SwiftUI




struct AnimatedLogoView: View {
    let isExpanded: Bool
    let animationDuration: Double
    
    @State private var showS = false
    @State private var showY = false
    @State private var showN = false
    @State private var showFirstC = false
    @State private var showSecondC = false
    @State private var showSlogan = false
    
    
    var body: some View {
//        ZStack(alignment: .bottom) {
//            Image("syncc_badge_dark")
//                .resizable()
//                .frame(width: 550, height: 310)
            
        VStack {
            Image("syncc_badge_dark")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
//            HStack(spacing: 0) {
                //                if showS {
                //                    Text("S")
                //                        .h1Style()
                //                }
                //
                //                if showY {
                //                    Text("y")
                //                        .h1Style()
                //                        .transition(.scale.combined(with: .opacity))
                //                }
                //
                //                if showN {
                //                    Text("n")
                //                        .h1Style()
                //                        .transition(.scale.combined(with: .opacity))
                //                }
                //
                //                if showFirstC {
                //                    Text("c")
                //                        .h1Style()
                //                        .transition(.scale.combined(with: .opacity))
                //                }
                //
                //                if showSecondC {
                //                    Text("c")
                //                        .h1Style()
                //                        .transition(.scale.combined(with: .opacity))
                //                }
//                VStack {
//                    Text("Syncc")
//                        .h1Style()
//                    
                    Text("Stay in Syncc, stay connected")
                        .h2Style()
//                }
//            }
//            .padding(.top, 220)
//            .frame(width: 300, height: 300)
        }
        .foregroundStyle(.syncBlack)
        .onChange(of: isExpanded) { oldValue, newValue in
            if newValue {
                animateExpansion()
            }
        }
    }
    
    private func animateExpansion() {
        withAnimation(.easeIn(duration: animationDuration * 0.4).delay(animationDuration * 0.4)) {
            showS = true
        }
        
        withAnimation(.easeIn(duration: animationDuration * 0.4).delay(animationDuration * 0.4)) {
            showY = true
        }
        
        withAnimation(.easeIn(duration: animationDuration * 0.4).delay(animationDuration * 0.6)) {
            showN = true
        }
        
        withAnimation(.easeIn(duration: animationDuration * 0.4).delay(animationDuration * 0.8)) {
            showFirstC = true
        }
        
        withAnimation(.easeIn(duration: animationDuration * 0.4).delay(animationDuration * 1.0)) {
            showSecondC = true
        }
    }
}



struct FullLogoView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("syncc_badge_dark")
                .resizable()
                .frame(width: 550, height: 310)
            
            HStack(spacing: 0) {
                Text("S")
                    .h1Style()
                
                Text("y")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("n")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("c")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("c")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
            }
            
        }
        .foregroundStyle(.syncBlack)
    }
}


#Preview {
    AnimatedLogoView(isExpanded: true, animationDuration: 2.0)
}
