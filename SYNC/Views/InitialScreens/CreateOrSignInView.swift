import SwiftUI
import WebKit
import RevenueCat



struct CreateOrSignInView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var logoOffset: CGFloat = 0
    @State private var logoInPosition = false
    
    @State private var showExpandedLogo = false
    @State private var showGradientBackground = false
    
    var bannedMessage: String
    
    
    @State private var isPresentEULA = false
    @State private var isPresentPrivacyPolicy = false
    
    
    var body: some View {
        VStack(spacing: 30) {
            AnimatedLogoView(isExpanded: showExpandedLogo, animationDuration: 1.5)
                .offset(y: logoOffset)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        withAnimation(.easeIn(duration: 1)) {
                            showExpandedLogo = true
                            logoOffset = -50
                            logoInPosition = true
                        }
                    }
                }
            
            
            if logoInPosition {
                homeOptionFields
            }
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
                WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
                    .ignoresSafeArea()
                    .navigationTitle("Privacy Policy")
                    .navigationBarTitleDisplayMode(.inline)
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
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
    }
    
    private var backgroundView: some View {
        Color.syncWhite
            .ignoresSafeArea()
    }
    
    
    // MARK: - Input Fields
    private var homeOptionFields: some View {
        VStack(spacing: 20) {
            VStack(alignment: .center) {
                Text("By creating an account with with Syncc")
                    .bodyTextStyle()
                
                Group {
                    Text("you agree to our ") + Text("Privacy policy ").bold() + Text("and agree")
                }
                .bodyTextStyle()
                .onTapGesture {
                    isPresentPrivacyPolicy = true
                }
                
                Group {
                    Text("to our ") + Text("End User License Agreement (EULA)").bold()
                }
                .bodyTextStyle()
                .onTapGesture {
                    isPresentEULA = true
                }
            }
            .multilineTextAlignment(.center)
            .font(.caption)
            .foregroundStyle(.syncBlack)
            .padding(.vertical, 6)
//            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .cornerRadius(8)
            
            
            NavigationLink {
                AuthLayerView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
            } label: {
                Text("Create account")
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



struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {

        let request = URLRequest(url: url)
        webView.load(request)
    }
}
