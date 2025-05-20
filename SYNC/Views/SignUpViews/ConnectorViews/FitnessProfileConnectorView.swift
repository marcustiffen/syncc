import SwiftUI



struct FitnessProfileConnectorView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Now onto your fitness profile!")
                }
                .titleModifiers()
                
                Spacer()
                
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
                            FitnessLevelView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
            
            
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
