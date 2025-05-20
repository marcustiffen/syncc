
import SwiftUI

struct FilteredMatchRadiusView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton()
                Spacer()
                OnBoardingNavigationLinkSkip {
                    //                        NavigationStack {
                    FilteredFitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    //                        }
                }
                .onTapGesture {
                    signUpModel.filteredMatchRadius = 50.0
                }
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "location.north.circle")
                Text("Choose your radius")
            }
            .titleModifiers()
            
            Text("Radius: \(Int(signUpModel.filteredMatchRadius)) km")
                .h2Style()
                .foregroundStyle(.syncBlack)
            
            Slider(value: $signUpModel.filteredMatchRadius, in: 0...100, step: 1)
                .tint(.syncBlack)
            
            Spacer()
            
            HStack {
                Spacer()
                OnBoardingNavigationLink(text: "Next") {
                    //                    NavigationStack {
                    FilteredFitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    //                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}

