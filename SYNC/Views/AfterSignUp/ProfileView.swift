import SwiftUI
import RevenueCat


struct ProfileView: View {
    @Binding var showCreateOrSignInView: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile Header
            headerSection
                .padding(.top, 50)
            
            // Profile Image and Edit Button
            profileImageSection
            
            // User Details
            userDetailsSection
            
            Spacer()
            // Profile Options
            accountNavigation
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        HStack {
            Text("profile")
                .foregroundStyle(.syncBlack)
            
            Spacer()
        }
        .h1Style()
        
//        .padding(.top, 20)
    }
    
    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // Profile Image
//            if let imageUrl = profileModel.user?.imageUrls?.first {
            if let image = profileModel.user?.images?.first {
                ImageLoaderView(urlString: image.url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    )
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 180, height: 180)
            }
            
            // Edit Profile Button
            NavigationLink(destination: EditProfileView()) {
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .foregroundColor(.syncGreen)
            }
            .offset(x: 10, y: 10)
        }
        .padding(.vertical, 20)
    }
    
    private var userDetailsSection: some View {
        HStack(spacing: 10) {
            Text(profileModel.user?.name ?? "User Name")
                .foregroundStyle(.syncBlack)
                .h2Style()
            
            if subscriptionModel.isSubscriptionActive {
                Image(systemName: "star.fill")
                    .font(.h2)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.bottom, 30)

    }
    
    private var accountNavigation: some View {
        NavigationLink {
            AccountView(showCreateOrSignInView: $showCreateOrSignInView)
        } label: {
            HStack {
                Image(systemName: "gear")
                    .foregroundStyle(.syncBlack)
                    .frame(width: 30)
                
                Text("Settings")
                    .foregroundStyle(.syncBlack)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.syncBlack)
            }
            .h2Style()
            .padding()
            .background(Color.syncGrey.opacity(0.1))
            .cornerRadius(12)
        }
    }
}


