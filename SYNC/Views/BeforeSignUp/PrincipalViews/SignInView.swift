import SwiftUI



struct SignInView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    
    
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    
    @State private var navigateToTabBarView = false

    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton { dismiss() }
                Spacer()
            }
            
            
            AnimatedLogoView(isExpanded: false, animationDuration: 1.5)
//                .padding(.bottom, 150)
            
            
//            VStack(spacing: 0) {
//                Image("syncc_badge_dark")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
                
//                HStack(spacing: 0) {
//                    Text("S")
//                        .h1Style()
//                    
//                    Text("y")
//                        .h1Style()
//                        .transition(.scale.combined(with: .opacity))
//                    
//                    Text("n")
//                        .h1Style()
//                        .transition(.scale.combined(with: .opacity))
//                    
//                    Text("c")
//                        .h1Style()
//                        .transition(.scale.combined(with: .opacity))
//                    
//                    Text("c")
//                        .h1Style()
//                        .transition(.scale.combined(with: .opacity))
//                }
//            }
            
            inputFields
                .padding(.top, 120)
            
            
            
        }
//        .navigationDestination(isPresented: $navigateToTabBarView, destination: {
//            TabbarView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                .environmentObject(profileModel)
//        })
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.syncWhite
                .ignoresSafeArea()
        )
        .alert("Error", isPresented: $showAlert, actions: {
            Button("Okay") {
                showAlert = false
            }
        }, message: {
            Text("Incorrect e-mail or password")
        })
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    

    private var inputFields: some View {
        VStack(spacing: 20) {
            CustomOnBoardingTextField(placeholder: "Email", image: "envelope.fill", text: $email)
                .textInputAutocapitalization(.never)
                .frame(height: 50)
            CustomOnBoardingSecureField(placeholder: "Password", image: "lock.fill", text: $password)
                .frame(height: 50)
            
            Button {
                Task {
                    do {
                        isLoading = true
                        try await signUpModel.signIn(email: email, password: password)
                        if let user = await profileModel.loadCurrentUser() {
//                            chatRoomsManager.addListenerChatRooms(userId: user.uid)
                            ChatRoomsManager().startListening(for: user.uid)
//                            completeUsersModel.callAllListenersForUser(userId: user.uid)
//                            completeUsersModel.setupAllListeners(currentUser: user)
                            
                        }
                        isLoading = false
                        showCreateOrSignInView = false
//                        navigateToTabBarView = true
//                        loadingViewFinishedLoading = false
                    } catch {
                        showAlert = true
                    }
                }
            } label: {
                if !isLoading {
                    Text("Log In")
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
            }
            .background(
                Rectangle()
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(.syncGreen)
            )
            
            Spacer()
            
            NavigationLink {
                ForgotPasswordView()
            } label: {
                Group {
                    Text("Forgot Password? ") + Text("Click here").bold()
                }
                .bodyTextStyle()
                .foregroundStyle(.syncBlack)
            }
        }
    }
}
