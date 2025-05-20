import Combine
import Firebase
import SwiftUI
import CoreLocation


struct LikeReceived: Codable {
    var userId: String
    var timestamp: Date
    
    init(timestamp: Date, userId: String) {
        self.timestamp = timestamp
        self.userId = userId
    }
    
    enum CodingKeys: CodingKey {
        case timestamp
        case userId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
    }
}




struct LikesReceivedView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    
    @State private var showPayWallView = false

    var body: some View {
        VStack(alignment: .center) {
            headerSection
                .padding(.top, 50)
            
            Spacer()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(completeUsersModel.likesReceivedUsers, id: \.uid) { user in
                        NavigationLink {
                            InspectUserView(user: user)
                        } label: {
                            MiniProfileCardView(showPayWallView: $showPayWallView, user: user)
                                .padding(2)
                        }
                        .disabled(subscriptionModel.isSubscriptionActive == false)
                    }
                }
                .padding(.leading, 10)
            }
            Spacer()
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
        .background(
            Color.white
                .ignoresSafeArea()
        )
        .overlay {
            if completeUsersModel.likesReceived.isEmpty == true {
                VStack {
                    Image("sync_badgeDark")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    Text("No syncc requests received!")
                        .multilineTextAlignment(.center)
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("syncc requests")
            
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
    }
}


struct MiniProfileCardView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    
//    @State private var showPayWallView = false
    @Binding var showPayWallView: Bool
    
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
                } /*else {
                    RoundedRectangle(cornerRadius: 10)
                   .scaledToFit
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .overlay(
                            Text("No images")
                                .foregroundColor(.gray)
                        )
                }*/

                
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
                
                HStack {
                    LikeButton(user: user) {
                        if subscriptionModel.isSubscriptionActive {
                            Task {
                                try await likeAction()
                            }
                        } else {
                            showPayWallView = true
                        }
                    }
                    
                    Spacer()
                    
                    DislikeButton(user: user) {
                        if subscriptionModel.isSubscriptionActive {
                            dislikeAction()
                        } else {
                            showPayWallView = true
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            .blur(radius: subscriptionModel.isSubscriptionActive ? 0 : 5)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 300, height: 450)
    }
    
    
    func likeAction() async throws {
        matchMakingManager.sendLike(currentUserId: profileModel.user?.uid ?? "", likedUserId: user.uid, isSubscriptionActive: subscriptionModel.isSubscriptionActive) { result in
            switch result {
            case .success:
                NotificationManager.shared.sendSingularPushNotification(token: user.fcmToken ?? "", message: "It's a match! Start a conversation with \(profileModel.user?.name ?? "") to sync up!", title: "Syncc") { result in
                    switch result {
                    case .success:
                        print("Success")
                    case .failure(let failure):
                        print("Failed to send notifcation: \(failure.localizedDescription)")
                    }
                }
                print("Like Sent")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func dislikeAction() {
        guard let currentUserId = profileModel.user?.uid else { return }
        Task {
            await matchMakingManager.dismissUser(currentUserId: currentUserId, dismissedUserId: user.uid)
            try await completeUsersModel.loadUsersForLikesReceived()
        }
    }
}


extension CLLocationCoordinate2D {
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return thisLocation.distance(from: otherLocation) / 1000.0 // Distance in kilometers
    }
}
