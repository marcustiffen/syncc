import Firebase
import FirebaseAuth
import SwiftUI


struct SplashView: View {
    @State private var isActive: Bool = false
    @StateObject var networkManager = NetworkManager()

    @StateObject var profileModel = ProfileModel()

    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var isLoading: Bool = false
    @State var loadingViewFinishedLoading: Bool = false
    @State var showCreateOrSignInView: Bool = false
    
    @State private var bannedMessage: String = ""
    
    @State private var loadingMessage = ""

    var body: some View {
        ZStack {
            if isActive {
                NavigationStack {
                    ContentView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, bannedMessage: bannedMessage)
                        .environmentObject(profileModel)
                        .environmentObject(chatRoomsManager)
                        .environmentObject(subscriptionModel)
                }
            } else {
                splashView
            }
        }
        .fullScreenCover(isPresented: $networkManager.isDisconnected) {
            VStack {
                Text("🚫 No Internet Connection")
                    .font(.title)
                    .padding()
            }
        }
        .onAppear {
            Task {
                await loadData()
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isLoading) {} content: {
            LoadingView(isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, loadingMessage: $loadingMessage)
        }
    }

    private var splashView: some View {
        ZStack {
            Color.syncWhite
                .ignoresSafeArea()
            
            AnimatedLogoView(isExpanded: false, animationDuration: 1.5)
                .offset(x: 0, y: 0)
        }
    }
    
    
    func loadData() async {
        if let user = await profileModel.loadCurrentUser() {
            if user.onboardingStep == .complete {
                if user.isBanned == false {
                    isLoading = true
                    chatRoomsManager.startListening(for: user.uid)
                    likesReceivedViewModel.addListenerForLikesReceived(for: user.uid)
                    showCreateOrSignInView = false
                    loadingViewFinishedLoading = true
                    if subscriptionModel.isSubscriptionActive == false {
                        await profileModel.resetNonAdmin(uid: user.uid)
                        print("User has no active sub - resetting status")
                    }
                } else {
                    bannedMessage = "You have been banned from Syncc"
                    showCreateOrSignInView = true
                    loadingViewFinishedLoading = false
                }
            } else {
                showCreateOrSignInView = true
                loadingViewFinishedLoading = false
            }
        } else {
            print("No authenticated user found.")
            showCreateOrSignInView = true
        }
    }
}
