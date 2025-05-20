import SwiftUI


struct CompleteSignUpView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    
    @State var completedLoading: Bool = false
//    @State private var signUpLoading: Bool = false
    
    @State private var finalLoading = false
    
    @State private var loadingMessage: String = ""
            
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton()
                Spacer()
            }
            .padding(.bottom, 40)
            
//            OnBoardingButton(text: "Start SYNCing up!") {
//                loadingMessage = "Creating account..."
//                isLoading = true
//                loadingViewFinishedLoading = false
//                Task {
//                    do {
//                        let newUser = try await signUpModel.createAccount()
//                        self.profileModel.user = newUser
//                        
//                        // Run all operations concurrently
//                        chatRoomsManager.addListenerChatRooms(userId: newUser.uid)
//                        completeUsersModel.callAllListenersForUser(userId: newUser.uid)
//                        await profileModel.setUserDeviceToken(uid: newUser.uid)
//                        
//                        // Hide the create/sign in view
//                        withAnimation {
//                            showCreateOrSignInView = false
//                        }
//                        
//                        // Signal that operations are complete
//                        loadingViewFinishedLoading = true
//                        completedLoading = true
//                    } catch {
//                        print("Error during sign up: \(error)")
//                        isLoading = false
//                    }
//                }
//            }
            OnBoardingButton(text: "Start SYNCing up!") {
                loadingMessage = "Creating account..."
                Task {
                    do {
                        finalLoading = true
                        let newUser = try await signUpModel.createAccount()
                        self.profileModel.user = newUser
                        
                        // Run all operations concurrently
                        chatRoomsManager.addListenerChatRooms(userId: newUser.uid)
                        completeUsersModel.callAllListenersForUser(userId: newUser.uid)
                        await profileModel.setUserDeviceToken(uid: newUser.uid)
                        
                        // Hide the create/sign in view
                        withAnimation {
                            showCreateOrSignInView = false
                        }
                        
                        // Signal that operations are complete
                        completedLoading = true
                        finalLoading = false
                    } catch {
                        print("Error during sign up: \(error)")
                        isLoading = false
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .fullScreenCover(isPresented: $finalLoading, content: {
            LoadingView(isLoading: $finalLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, loadingMessage: $loadingMessage)
        })
        .navigationDestination(isPresented: $completedLoading, destination: {
            TabbarView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
        })
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
