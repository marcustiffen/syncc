import Combine
import Firebase
import SwiftUI
import CoreLocation








struct LikesReceivedView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
//    @StateObject var likesReceivedViewModel = LikesReceivedViewModel()
//    @StateObject private var notificationManager = NotificationManager.shared
    
    @EnvironmentObject var likesReceivedViewModel: LikesReceivedViewModel
    
    @State private var showPayWallView = false

    var body: some View {
        VStack(alignment: .center) {
//            headerSection
//                .padding(.top, 50)
            
            if likesReceivedViewModel.isLoading {
                ProgressView("Loading users...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if likesReceivedViewModel.usersWhoLiked.isEmpty {
                emptyStateView
            } else {
                likesReceivedContent
            }
            
            Spacer()
        }
        .sheet(isPresented: $showPayWallView) {
            PayWallView(isPaywallPresented: $showPayWallView)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
//    private var headerSection: some View {
//        HStack {
//            Text("Syncc requests")
//            Spacer()
//        }
//        .h1Style()
//        .foregroundStyle(.syncBlack)
//        .padding(.horizontal, 10)
//    }
    
    private var emptyStateView: some View {
        VStack {
            Image("sync_badgeDark")
                .resizable()
                .frame(width: 200, height: 200)
            
            Text("No Syncc requests received!")
                .multilineTextAlignment(.center)
                .h2Style()
                .foregroundStyle(.syncBlack)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var likesReceivedContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(likesReceivedViewModel.animatedUsers, id: \.uid) { user in
                    NavigationLink {
                        InspectUserView(likeAction: {
                            if subscriptionModel.isSubscriptionActive {
                                likesReceivedViewModel.sendLike(currentUser: profileModel.user!, user: user, isSubscriptionActive: subscriptionModel.isSubscriptionActive)
                            } else {
                                showPayWallView = true
                            }
                        }, dislikeAction: {
                            if subscriptionModel.isSubscriptionActive {
                                likesReceivedViewModel.sendDislike(currentUser: profileModel.user!, user: user)
                            } else {
                                showPayWallView = true
                            }
                        }, user: user)
                    } label: {
                        MiniProfileCardView(showPayWallView: $showPayWallView, likeAction: {
                            if subscriptionModel.isSubscriptionActive {
                                likesReceivedViewModel.sendLike(currentUser: profileModel.user!, user: user, isSubscriptionActive: subscriptionModel.isSubscriptionActive)
                            } else {
                                showPayWallView = true
                            }
                        }, dislikeAction: {
                            if subscriptionModel.isSubscriptionActive {
                                likesReceivedViewModel.sendDislike(currentUser: profileModel.user!, user: user)
                            } else {
                                showPayWallView = true
                            }
                        }, user: user)
                            .padding(2)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8)
                                    .combined(with: .opacity)
                                    .combined(with: .offset(y: 20)),
                                removal: .scale(scale: 0.8)
                                    .combined(with: .opacity)
                            ))
                    }
                    .disabled(subscriptionModel.isSubscriptionActive == false)
                }
            }
            .padding(.leading, 10)
        }
    }
    
    
    
    
    

}


struct MiniProfileCardView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @Binding var showPayWallView: Bool
    @State private var isVisible = false
    
    var likeAction: () -> Void
    var dislikeAction: () -> Void
    
    var user: DBUser
    var usersFirstName: String {
        return user.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    @StateObject var matchMakingManager = MatchMakingManager()
    
    var body: some View {
        ZStack {
            Rectangle()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.syncWhite)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 10) {
                if let image = user.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 300)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.9)
                        .animation(.easeOut(duration: 0.3).delay(0.1), value: isVisible)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 300)
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(usersFirstName)")
                            .font(.system(size: 24))
                            .foregroundStyle(.syncBlack)
                        Text(user.fitnessLevel ?? "Fitness Level")
                            .font(.system(size: 20))
                            .foregroundStyle(.syncGrey)
                    }
                    
                    Spacer()
                    Text("\(user.age ?? 0)")
                        .font(.system(size: 24))
                }
                .foregroundStyle(.syncBlack)
                .font(.system(size: 24))
                .bold()
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: isVisible)
                
                HStack {
                    LikeButton(user: user) {
//                        if subscriptionModel.isSubscriptionActive {
//                            Task {
//                                try await likeAction()
//                            }
//                        } else {
//                            showPayWallView = true
//                        }
                        likeAction()
                    }
                    
                    Spacer()
                    
                    DislikeButton(user: user) {
//                        if subscriptionModel.isSubscriptionActive {
//                            dislikeAction()
//                        } else {
//                            showPayWallView = true
//                        }
                        dislikeAction()
                    }
                }
                .padding(.bottom, 10)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 15)
                .animation(.easeOut(duration: 0.3).delay(0.3), value: isVisible)
            }
            .padding(.horizontal, 20)
            .blur(radius: subscriptionModel.isSubscriptionActive ? 0 : 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 300, height: 450)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                isVisible = true
            }
        }
    }
    
//    func likeAction() async throws {
//        
//    }
//    
//    func dislikeAction() {
//        
//    }
}


extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return thisLocation.distance(from: otherLocation) / 1000.0 // Distance in kilometers
    }
}
