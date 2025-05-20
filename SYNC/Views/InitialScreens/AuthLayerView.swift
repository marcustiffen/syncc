import SwiftUI
import FirebaseAuth

struct AuthLayerView: View {
    @State private var showEmailLayer: Bool = false
    @State private var showOnboardFlow: Bool = false
    
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    var body: some View {
        ZStack {
            if showEmailLayer == false && showOnboardFlow == false {
                PhoneAuthenticationView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, showEmailLayer: $showEmailLayer, showOnBoardingView: $showOnboardFlow)
            } else if showEmailLayer == true && showOnboardFlow == false {
                EmailView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, showEmailLayer: $showEmailLayer, showOnBoardingView: $showOnboardFlow)
            } else if showEmailLayer == true && showOnboardFlow == true {
                WelcomeConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, showOnBoardingView: $showOnboardFlow, showEmailLayer: $showEmailLayer)
            }
        }
        .onChange(of: showEmailLayer) { oldValue, newValue in
            print("Show email layer changed")
        }
        .onChange(of: showOnboardFlow) { oldValue, newValue in
            print("Show onboard flow layer changed")
        }
    }
}
