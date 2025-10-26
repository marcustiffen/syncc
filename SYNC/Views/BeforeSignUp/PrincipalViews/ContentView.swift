import SwiftUI
import Foundation
import Combine


struct ContentView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool

    @StateObject private var networkManager = NetworkManager()
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var subscriptionModel: SubscriptionModel

    let bannedMessage: String

    var body: some View {
        ZStack {
            if showCreateOrSignInView {
                CreateOrSignInView(
                    showCreateOrSignInView: $showCreateOrSignInView,
                    isLoading: $isLoading,
                    loadingViewFinishedLoading: $loadingViewFinishedLoading,
                    bannedMessage: bannedMessage
                )
                .environmentObject(profileModel)
                .environmentObject(chatRoomsManager)
                .environmentObject(subscriptionModel)
            } else {
                TabbarView(
                    showCreateOrSignInView: $showCreateOrSignInView,
                    isLoading: $isLoading,
                    loadingViewFinishedLoading: $loadingViewFinishedLoading
                )
                .environmentObject(profileModel)
                .environmentObject(chatRoomsManager)
                .environmentObject(subscriptionModel)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showCreateOrSignInView)
    }
}




