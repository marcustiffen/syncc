import SwiftUI
import RevenueCat



struct CreateOrSignInView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @StateObject var signUpModel = SignUpModel()
    
    @State private var logoOffset: CGFloat = 0
    @State private var logoInPosition = false
    
    @State private var showExpandedLogo = false
    @State private var showGradientBackground = false
    
    var bannedMessage: String
    
    
    @State private var isPresentEULA = false
    @State private var isPresentPrivacyPolicy = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            AnimatedLogoView(isExpanded: showExpandedLogo, animationDuration: 1.5)
                .padding(.bottom, 150)

//                .offset(y: logoOffset)
//                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now()) {
//                        withAnimation(.easeIn(duration: 1)) {
//                            showExpandedLogo = true
//                            logoOffset = -50
//                            logoInPosition = true
//                        }
//                    }
//                }
            
                        
            
//            if logoInPosition {
            homeOptionFields
//            }
        }
        .sheet(isPresented: $isPresentEULA) {
            NavigationStack {
                WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .ignoresSafeArea()
                    .navigationTitle("EULA")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $isPresentPrivacyPolicy) {
            NavigationStack {
                WebView(url: URL(string: "https://www.syncc.com.au/privacy")!)
//                WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
//                    .ignoresSafeArea()
//                    .navigationTitle("Privacy Policy")
//                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            loadingViewFinishedLoading = false
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if bannedMessage != "" {
                Text(bannedMessage)
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
    }
    
    private var backgroundView: some View {
        Color.syncWhite
            .ignoresSafeArea()
    }
    
    
    private var homeOptionFields: some View {
        VStack(spacing: 20) {
            
            VStack(alignment: .center, spacing: 4) {
                TappableTextView(
                    fullText: "By creating an account with Syncc, you agree to our Privacy Policy and End User License Agreement (EULA)",
                    tappableTexts: ["Privacy Policy", "End User License Agreement (EULA)"],
                    onTap: { tappedText in
                        if tappedText == "Privacy Policy" {
                            isPresentPrivacyPolicy = true
                        } else if tappedText == "End User License Agreement (EULA)" {
                            isPresentEULA = true
                        }
                    }, font: Font.custom("Poppins-Regular", size: 12)
                )
            }
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            
            
            NavigationLink {
                OnBoardingManagerView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    .environmentObject(signUpModel)
                    .environmentObject(chatRoomsManager)
                    .environmentObject(profileModel)
            } label: {
                Text(signUpModel.onboardingStep == .phone ? "Create account" : "Continue account creation")
                    .foregroundStyle(.syncBlack)
                    .h2Style()
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
             }
            .background(
                Rectangle()
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(.syncGreen)
            )
            .animation(.easeInOut(duration: 0.2), value: true)
            .scaleEffect(0.95)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            
            NavigationLink {
                SignInView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    .environmentObject(signUpModel)
                    .environmentObject(profileModel)
                    .environmentObject(chatRoomsManager)
                    .environmentObject(subscriptionModel)
            } label: {
                Text("Sign in")
                    .foregroundStyle(.syncBlack)
                    .h2Style()
            }
            .animation(.easeInOut(duration: 0.2), value: true)
            .scaleEffect(0.95)
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}





