import Firebase
import FirebaseAuth
import SwiftUI


struct SplashView: View {
    @State private var showCreateOrSignInView: Bool = false
    @State private var isActive: Bool = false
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var isLoading: Bool = false
    @State var loadingViewFinishedLoading = false
    
    @State private var bannedMessage: String = ""
    
    @State private var loadingMessage = ""

    var body: some View {
        ZStack {
            if isActive {
                NavigationStack {
                    ContentView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, bannedMessage: bannedMessage)
                }
            } else {
                splashView
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
            LoadingView(isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, loadingMessage: $signUpModel.loadingMessage)
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

    private func loadData() async {
        if let user = await profileModel.loadCurrentUser() {
            if user.isBanned == false {
                loadingMessage = "Loading profile..."
                isLoading = true
                chatRoomsManager.addListenerChatRooms(userId: user.uid)
                completeUsersModel.callAllListenersForUser(userId: user.uid)
                showCreateOrSignInView = false
                loadingViewFinishedLoading = true
            } else {
                bannedMessage = "You have been banned from Syncc"
                showCreateOrSignInView = true
                loadingViewFinishedLoading = false
            }
        } else {
            print("No authenticated user found.")
            showCreateOrSignInView = true
        }
    }
    
}
