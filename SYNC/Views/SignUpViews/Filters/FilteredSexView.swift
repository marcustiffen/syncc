
import SwiftUI

struct FilteredSexView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var sexes = ["Male", "Female", "Both"]
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
//                        NavigationStack {
                            FilteredMatchRadiusView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                        }
                    }
                    .onTapGesture {
                        signUpModel.filteredSex = "Both"
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "person.2")
                    Text("Choose the sex(es) do you want to sync up with")
                }
                .titleModifiers()
                
                CustomSegmentPicker(options: sexes, selected: $signUpModel.filteredSex)
                
                Spacer()
                
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
    //                    NavigationStack {
                            FilteredMatchRadiusView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
    //                    }
                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
