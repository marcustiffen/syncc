import SwiftUI
import RevenueCat


struct AccountView: View {
    @Binding var showCreateOrSignInView: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel

    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteConfirmation = false
    @State private var navigateToCreateOrSignInView = false
    @State private var isPresentEULA = false
    @State private var isPresentPrivacyPolicy = false
    
    @State private var navigateToConfirmDeletionView = false
    
    var body: some View {
        VStack {
            HStack {
                SyncBackButton { dismiss() }
                Spacer()
            }
            Spacer()
            profileOptionsSection
        }
        .sheet(isPresented: $isPresentPrivacyPolicy) {
            WebView(url: URL(string: "https://www.freeprivacypolicy.com/live/eb4dff28-4b8f-49aa-8154-179310a1ec20")!)
        }
        .sheet(isPresented: $isPresentEULA) {
            WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
        .navigationDestination(isPresented: $navigateToCreateOrSignInView, destination: {
            CreateOrSignInView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: .constant(false), loadingViewFinishedLoading: .constant(false), bannedMessage: "")
        })
        .navigationDestination(isPresented: $navigateToConfirmDeletionView, destination: {
            ConfirmDeletionView(showCreateOrSignInView: $showCreateOrSignInView)
        })
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to permanently delete your account?"),
                primaryButton: .destructive(Text("Delete")) {
//                    Task {
//                        do {
//                            try await profileModel.deleteUser()
//                            navigateToCreateOrSignInView = true
//                        } catch {
//                            showDeleteConfirmation = false
//                        }
//                    }
                    navigateToConfirmDeletionView = true
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var profileOptionsSection: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ProfileOptionView(
                    icon: "doc.text",
                    title: "View EULA",
                    color: .blue,
                    action: {
                        isPresentEULA = true
                    }
                )
                
                ProfileOptionView(
                    icon: "lock.doc",
                    title: "View Privacy policy",
                    color: .blue,
                    action: {
                        isPresentPrivacyPolicy = true
                    }
                )
                
                Spacer()
                
                //Restore purchases
                ProfileOptionView(
                    icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90",
                    title: "Restore Purchases",
                    color: .blue,
                    action: {
                        Purchases.shared.restorePurchases { (customerInfo, error) in
                            subscriptionModel.isSubscriptionActive = customerInfo?.entitlements.all["pro"]?.isActive == true
                        }
                    }
                )
                
                ProfileOptionView(
                    icon: "creditcard",
                    title: "Manage Subscription",
                    color: .blue,
                    action: {
                        Purchases.shared.showManageSubscriptions { error in
                            if let error = error {
                                print("Failed to open subscription management: \(error.localizedDescription)")
                                // Optionally, show an alert to the user
                            } else {
                                print("Opened subscription management successfully.")
                            }
                        }
                    }
                )
                
                Spacer()
                
                // Logout Option
                ProfileOptionView(
                    icon: "arrow.right.square",
                    title: "Log Out",
                    color: .blue,
                    action: {
                        Task {
                            do {
                                try profileModel.signOut()
                                //                            withAnimation {
                                //                                showCreateOrSignInView = true
                                //                            }
                                navigateToCreateOrSignInView = true
                            } catch {
                                print("Logout failed: \(error)")
                            }
                        }
                    }
                )
                
                // Delete Account Option
                ProfileOptionView(
                    icon: "trash",
                    title: "Delete Account",
                    color: .red,
                    action: {
                        showDeleteConfirmation = true
                    }
                )
                
            }
            .padding(.horizontal, 20)
        }
    }
}



