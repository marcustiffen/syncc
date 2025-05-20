import SwiftUI

struct WelcomeConnectorView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    @Binding var showOnBoardingView: Bool
    @Binding var showEmailLayer: Bool
    
    @EnvironmentObject var signUpModel: SignUpModel
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack { }
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome to Syncc! Now lets go ahead and make your profile!")
            }
            .titleModifiers()
            
            Spacer()
            
            HStack {
                Spacer()
                OnBoardingNavigationLink(text: "Next") {
                    NameView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
