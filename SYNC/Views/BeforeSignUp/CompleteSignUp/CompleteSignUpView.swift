import SwiftUI


struct CompleteSignUpView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    
    @State var completedLoading: Bool = false
    
    @State private var finalLoading = false
    
    @State private var loadingMessage: String = ""
            
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredFitnessLevel
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredFitnessLevel)
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            OnBoardingButton(text: "Start SYNCing up!") {
                Task {
                    do {
                        finalLoading = true
                        let newUser = try await signUpModel.createAccount()
                        self.profileModel.user = newUser
                        
                        // Run all operations concurrently
//                        chatRoomsManager.addListenerChatRooms(userId: newUser.uid)
//                        ChatRoomsManager().startListening(for: newUser.uid)
//                        completeUsersModel.callAllListenersForUser(userId: newUser.uid)
//                        completeUsersModel.setupAllListeners(currentUser: newUser)
                        
                        chatRoomsManager.startListening(for: newUser.uid)
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
//                Task {
//                    do {
//                        finalLoading = true
//                        
//                        let newUser = try await signUpModel.setUser()
//                        profileModel.user = newUser
//                        
//                        ChatRoomsManager().startListening(for: newUser.uid)
//                        completeUsersModel.setupAllListeners(currentUser: newUser)
//                        
//                        await profileModel.setUserDeviceToken(uid: newUser.uid)
//                        // Hide the create/sign in view
//                        withAnimation {
//                            showCreateOrSignInView = false
//                        }
//                        
//                        // Signal that operations are complete
//                        completedLoading = true
//                        finalLoading = false
//                    } catch {
//                        print("Error during sign up: \(error)")
//                        isLoading = false
//                    }
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .fullScreenCover(isPresented: $finalLoading, content: {
            LoadingView(isLoading: $finalLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading, loadingMessage: $loadingMessage)
        })
        .navigationDestination(isPresented: $completedLoading, destination: {
            TabbarView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                .environmentObject(profileModel)
        })
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
