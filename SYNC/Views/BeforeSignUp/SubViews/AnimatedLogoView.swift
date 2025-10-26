
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
        ZStack(alignment: .bottom) {
            Image("sync_badgeDark")
                .resizable()
                .frame(width: 300, height: 300)
            
            HStack(spacing: 40) {
                if showS {
                    Text("S")
                        .h1Style()
//                        .font(.system(size: 36))
                }
                
                if showY {
                    Text("Y")
                        .h1Style()
//                        .font(.system(size: 36))
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showN {
                    Text("N")
                        .h1Style()
//                        .font(.system(size: 36))
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showFirstC {
                    Text("C")
                        .h1Style()
//                        .font(.system(size: 36))
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showSecondC {
                    Text("C")
                        .h1Style()
//                        .font(.system(size: 36))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.top, 200)
            .frame(width: 300, height: 300)
        }
//        }
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
            Image("sync_badgeDark")
                .resizable()
                .frame(width: 300, height: 300)
            
            HStack(spacing: 40) {
                Text("S")
                    .h1Style()
                
                
                Text("Y")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("N")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("C")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
                
                Text("C")
                    .h1Style()
                    .transition(.scale.combined(with: .opacity))
            }
            .padding(.top, 200)
            .frame(width: 300, height: 300)
        }
        .foregroundStyle(.syncBlack)
    }
}


#Preview {
    AnimatedLogoView(isExpanded: true, animationDuration: 2.0)
}
