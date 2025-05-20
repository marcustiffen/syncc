import SwiftUI

struct BioView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
        
    var body: some View {
            VStack(spacing: 40) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                            ImageSelectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                    .onTapGesture {
                        signUpModel.bio = ""
                    }
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "book")
                    Text("Enter your bio")
                }
                .titleModifiers()
                
                CustomOnBoardingTextEditor(text: $signUpModel.bio, placeholder: "Start typing here...")
                
                Spacer(minLength: 70)
                
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
                            ImageSelectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
