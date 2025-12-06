import SwiftUI


struct LikeButton: View {
    @State private var buttonTapped = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var glowIntensity: Double = 0
    
    var user: DBUser
    var likeAction: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                scaleEffect = 1.2
                glowIntensity = 1.5  // Increase glow
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    scaleEffect = 1.0
                    glowIntensity = 0  // Fade glow out
                }
            }
            hapticFeedback()
            likeAction()
        } label: {
           Image("Syncc_thumbs_up_fill")
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(.syncGreen)
                .clipShape(Circle())
        }
        .scaleEffect(scaleEffect)
        .disabled(buttonTapped == true)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}



struct DislikeButton: View {
    @State private var buttonTapped = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var glowIntensity: Double = 0
    
    var user: DBUser
    var dislikeAction: () -> Void
    
    
    var body: some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                scaleEffect = 1.2
                glowIntensity = 1.5  // Increase glow
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    scaleEffect = 1.0
                    glowIntensity = 0  // Fade glow out
                }
            }
            hapticFeedback()
            dislikeAction()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(.white)
                .clipShape(Circle())
        }
        .scaleEffect(scaleEffect)
        .disabled(buttonTapped == true)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}



struct SynccUpButton: View {
    @State private var buttonTapped = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var glowIntensity: Double = 0
    
    var user: DBUser
    var dislikeAction: () -> Void
    
    
    var body: some View {
        Button {
            withAnimation(.easeIn(duration: 0.2)) {
                scaleEffect = 1.2
                glowIntensity = 1.5  // Increase glow
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring()) {
                    scaleEffect = 1.0
                    glowIntensity = 0  // Fade glow out
                }
            }
            hapticFeedback()
            dislikeAction()
        } label: {
            Text("Syncc")
                .h2Style()
                .bold()
                .foregroundStyle(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.syncGreen)
                )
        }
        .scaleEffect(scaleEffect)
        .disabled(buttonTapped == true)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
