import SwiftUI


struct FitnessLevelView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var fitnessLevel: Double = 1 // Default to 1 (Beginner)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                SyncBackButton()
                Spacer()
            }
            .padding(.bottom, 40)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "figure.highintensity.intervaltraining")
                Text("What Fitness Level Are you")
            }
            .titleModifiers()
            
            Slider(value: $fitnessLevel, in: 1...8, step: 1)
                .accentColor(.syncBlack)
                .animation(.easeIn, value: fitnessLevel)
            
            Text("Your fitness level: \(signUpModel.fitnessLevel)")
                .foregroundStyle(.syncBlack)
                .h2Style()
            
            Spacer()
            
            HStack {
                Spacer()
                OnBoardingNavigationLink(text: "Next") {
                    FitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onChange(of: fitnessLevel) { oldValue, newValue in
            signUpModel.fitnessLevel = fitnessDescription(for: Int(newValue))
        }
    }
    
    func fitnessDescription(for level: Int) -> String {
        switch level {
        case 1: return "Beginner"
        case 2: return "Casual"
        case 3: return "Active"
        case 4: return "Intermediate"
        case 5: return "Enthusiast"
        case 6: return "Advanced"
        case 7: return "Athlete"
        case 8: return "Elite"
        default: return "Any"
        }
    }
}
