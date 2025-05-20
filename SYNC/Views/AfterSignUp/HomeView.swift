import SwiftUI
import CoreLocation
import Foundation
import FirebaseFirestore


struct HomeView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @Binding var showCreateOrSignInView: Bool
    @StateObject var matchMakingManager = MatchMakingManager()
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    
    @State private var cardOpacity: Double = 1.0
    @State private var isAnimating: Bool = false
    
    @State private var showPayWallView: Bool = false
    
    @State private var selectedIndex: Int = 0

    @Binding var loadingViewFinishedLoading: Bool
    @Binding var isLoading: Bool
        
    var body: some View {
        VStack {
            filterView()
                .padding(.top, 50)
            
            Spacer()
            ZStack {
                ForEach(Array(filteredUsers().enumerated()), id: \.offset) { (index, user) in
//                    let isPrevious = (selectedIndex - 1) == index
                    let isCurrent = selectedIndex == index
                    let isNext = (selectedIndex + 1) == index
                    
                    if isCurrent || isNext {
                        ProfileCardView(user: user, isCurrentUser: false, likeAction: {
//                            if subscriptionModel.isSubscriptionActive == true {
                                likeAction(user: user)
//                            }
                        }, dislikeAction: {
                            dislikeAction(user: user)
                        })
                    }
                }
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
        .overlay {
            if filteredUsers().isEmpty == true {
                VStack(alignment: .center) {
                    Image("sync_badgeDark")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    Text("No users available! Update filters")
                        .multilineTextAlignment(.center)
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
    }
    
    private func animateFadeOut(completion: @escaping () -> Void) {
        guard !isAnimating else { return }
        isAnimating = true
        
        // Fade out card
        withAnimation(.easeOut(duration: 0.5)) {
            cardOpacity = 0
        }
        
        // Run completion and reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completion()
            selectedIndex += 1
            if selectedIndex >= filteredUsers().count {
                selectedIndex = 0
            }
            cardOpacity = 1.0
            isAnimating = false
        }
    }
    
    
    private func filteredUsers() -> [DBUser] {
        return completeUsersModel.allUsers.filter { dbUser in
            // First check if user should be excluded
            guard !completeUsersModel.excludedUserIds.contains(dbUser.uid) else {
                return false
            }
            
            // Sex filter
            if let filteredSex = profileModel.user?.filteredSex,
               filteredSex != "Both",
               let userSex = dbUser.sex,
               userSex != filteredSex {
                return false
            }
            
            // Age filter
            if let filteredAgeRange = profileModel.user?.filteredAgeRange,
               let userAge = dbUser.age,
               (userAge < filteredAgeRange.min || userAge > filteredAgeRange.max) {
                return false
            }
            
            // Location filter
            if let currentUserLocation = profileModel.user?.location,
               let matchRadius = profileModel.user?.filteredMatchRadius,
               let userLocation = dbUser.location {
                let distance = currentUserLocation.location.distance(to: userLocation.location)
                if distance > Double(matchRadius) {
                    return false
                }
            }
            
            // Fitness level filter
            if let currentUserFitnessLevel = profileModel.user?.filteredFitnessLevel,
               currentUserFitnessLevel != "Any",
               let userFitnessLevel = dbUser.fitnessLevel,
               !currentUserFitnessLevel.isEmpty,
               !userFitnessLevel.isEmpty,
               currentUserFitnessLevel != userFitnessLevel {
                return false
            }
            
            // Fitness types filter
            if let filteredTypes = profileModel.user?.filteredFitnessTypes,
               !filteredTypes.isEmpty,
               let userTypes = dbUser.fitnessTypes {
                let filteredIds = Set(filteredTypes.map { $0.id })
                let userIds = Set(userTypes.map { $0.id })
                if filteredIds.isDisjoint(with: userIds) {
                    return false
                }
            }
            
            // Fitness goals filter
            if let filteredGoals = profileModel.user?.filteredFitnessGoals,
               !filteredGoals.isEmpty,
               let userGoals = dbUser.fitnessGoals {
                let filteredIds = Set(filteredGoals.map { $0.id })
                let userIds = Set(userGoals.map { $0.id })
                if filteredIds.isDisjoint(with: userIds) {
                    return false
                }
            }
            
            return true
        }
    }

    private func filterView() -> some View {
        HStack {
            Text("discover")
            Spacer()
            NavigationLink(
                destination:
                    FilterView(
                        isLoading: $isLoading,
                        filteredAgeRange: Binding(
                            get: { profileModel.user?.filteredAgeRange },
                            set: { profileModel.user?.filteredAgeRange = $0 }
                        ),
                        filteredSex: Binding(
                            get: { profileModel.user?.filteredSex },
                            set: { profileModel.user?.filteredSex = $0 }
                        ),
                        filteredMatchRadius: Binding(
                            get: { profileModel.user?.filteredMatchRadius },
                            set: { profileModel.user?.filteredMatchRadius = $0 }
                        ),
                        filteredFitnessTypes: Binding(
                            get: { profileModel.user?.filteredFitnessTypes },
                            set: { profileModel.user?.filteredFitnessTypes = $0 }
                        ),
                        filteredFitnessGoals: Binding(
                            get: { profileModel.user?.filteredFitnessGoals },
                            set: { profileModel.user?.filteredFitnessGoals = $0 }
                        ),
                        filteredFitnessLevel: Binding(
                            get: { profileModel.user?.filteredFitnessLevel ?? "" },
                            set: { profileModel.user?.filteredFitnessLevel = $0 }
                        ), loadingViewFinishedLoading: $loadingViewFinishedLoading
                    )
            ) {
                Image(systemName: "slider.horizontal.3")
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
    
    private func likeAction(user: DBUser) {
        var message: String = ""
        if !completeUsersModel.likesReceived.contains(where: { $0.userId == user.uid }) {
            message = "\(profileModel.user?.name ?? "") wants to syncc up!"
        } else {
            message = "It's a match! Start a conversation to syncc up!"
        }
        
        matchMakingManager.sendLike(currentUserId: profileModel.user?.uid ?? "", likedUserId: user.uid, isSubscriptionActive: subscriptionModel.isSubscriptionActive) { result in
            switch result {
            case .success:
                NotificationManager.shared.sendSingularPushNotification(token: user.fcmToken ?? "", message: message, title: "Syncc") { result in
                    switch result {
                    case .success:
                        print("Success")
                    case .failure(let failure):
                        print("Failed to send notifcation: \(failure.localizedDescription)")
                    }
                }
                print("Like Sent")
            case .failure(let error):
                showPayWallView = true
                print("Cannot send like")
            }
        }
    }
    
    private func dislikeAction(user: DBUser) {
        guard let currentUserId = profileModel.user?.uid else { return }
        Task {
            await matchMakingManager.dismissUser(currentUserId: currentUserId, dismissedUserId: user.uid)
        }
    }
}
