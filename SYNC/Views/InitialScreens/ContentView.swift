import SwiftUI


struct ContentView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    let bannedMessage: String
    
    var body: some View {
//        NavigationStack {
            ZStack {
                if showCreateOrSignInView {
                    CreateOrSignInView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, bannedMessage: bannedMessage)
                } else {
                    TabbarView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showCreateOrSignInView)
//        }
    }
}
