import SwiftUI


struct LoadingView: View {
    @State private var fullSineProgress: CGFloat = 0
    @State private var joiningSineProgress: CGFloat = 0
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @State private var hasStartedFinalAnimation: Bool = false
    
    @Binding var loadingMessage: String
//    @State var loadingMessage = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.syncWhite)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            FullSine()
                .trim(from: 0, to: fullSineProgress)
                .stroke(.syncBlack, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 250, height: 250)
            
            JoiningSine(startX: 35)
                .trim(from: 0, to: joiningSineProgress)
                .stroke(.syncBlack, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 250, height: 250)
            
            Text(loadingMessage)
                .padding(.top, 225)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        animate()
        checkLoadingStatus()
    }
    
    private func checkLoadingStatus() {
        guard !hasStartedFinalAnimation else { return }
        
        if loadingViewFinishedLoading {
            hasStartedFinalAnimation = true
            animateAndDismiss()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                checkLoadingStatus()
            }
        }
    }
    
    private func animate() {
        guard isLoading && !hasStartedFinalAnimation else { return }

        fullSineProgress = 0
        joiningSineProgress = 0

        withAnimation(.easeIn(duration: 0.8)) {
            fullSineProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.8)) {
                joiningSineProgress = 1.0
            }
        }

        // If operations aren't complete, continue animating
        if !loadingViewFinishedLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                animate()
            }
        }
    }
    
    private func animateAndDismiss() {
        // Run one final animation cycle
        withAnimation(.easeIn(duration: 0.8)) {
            fullSineProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.8)) {
                joiningSineProgress = 1.0
            }
            
            // Dismiss after the final animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
        }
    }
}



struct CompleteLoadingView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.syncWhite)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            FullSine()
                .trim(from: 0, to: 1.0)
                .stroke(.syncBlack, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 250, height: 250)
            
            JoiningSine(startX: 35)
                .trim(from: 0, to: 1.0)
                .stroke(.syncBlack, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 250, height: 250)
        }
    }
}


struct FullSine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let amplitude = rect.height / 4
            let wavelength = rect.width
            
            path.move(to: CGPoint(x: 0, y: rect.midY))
            
            for x in stride(from: 0, through: rect.width, by: 1) {
                let y = rect.midY + amplitude * sin(((2 * .pi / wavelength) * x) + .pi)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
}


struct JoiningSine: Shape {
    let startX: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            //Top
            let amplitude = rect.height / 4
            let wavelength = rect.width
            
            let phaseShift = (2 * .pi / wavelength) * startX
            
            path.move(to: CGPoint(x: startX, y: rect.midY + phaseShift))
            
            for x in stride(from: startX, through: (rect.width / 2) + startX, by: 1) {
                let y = rect.midY + amplitude * sin(((2 * .pi / wavelength) * x) + .pi - phaseShift)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            //Bottom
            let newStartX = startX + 125
            let startY = rect.midY + amplitude * sin(((2 * .pi / wavelength) * newStartX) + .pi - phaseShift)
            
            let endY = rect.midY + amplitude * sin(((2 * .pi / wavelength) * rect.width) + .pi)
            
            let startPoint = CGPoint(x: newStartX, y: startY)
            let endPoint = CGPoint(x: rect.width, y: endY)
            
            let control1 = CGPoint(x: newStartX + (rect.width - newStartX) * 0.3,
                                 y: startY + amplitude * 0.8)
            let control2 = CGPoint(x: newStartX + (rect.width - newStartX) * 0.7,
                                 y: endY + amplitude * 0.8)
            
            path.move(to: startPoint)
            path.addCurve(to: endPoint,
                         control1: control1,
                         control2: control2)
        }
        
    }
    
    init(startX: CGFloat = 20) {
        self.startX = startX
    }
}
