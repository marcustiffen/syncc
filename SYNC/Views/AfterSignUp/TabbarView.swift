import SwiftUI

//struct TabbarView: View {
//    @Binding var showCreateOrSignInView: Bool
//    @Binding var isLoading: Bool
//    
//    var body: some View {
//        TabView {
//            NavigationStack {
//                HomeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading)
//            }
//            .tabItem { Image(systemName: "house") }
//            
//            NavigationStack {
//                LikesReceivedView()
//            }
//            .tabItem { Image(systemName: "suit.heart.fill") }
//            
//            NavigationStack {
//                ChatRoomsView()
//            }
//            .tabItem { Image(systemName: "bubble") }
//            
//            NavigationStack {
//                ProfileView(showCreateOrSignInView: $showCreateOrSignInView)
//            }
//            .tabItem { Image(systemName: "person") }
//        }
//    }
//}


struct TabbarView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @State private var selectedTab = 0
    @Binding var loadingViewFinishedLoading: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            ZStack {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        HomeView(showCreateOrSignInView: $showCreateOrSignInView, loadingViewFinishedLoading: $loadingViewFinishedLoading, isLoading: $isLoading)
                    }
                case 1:
                    NavigationStack {
                        LikesReceivedView()
                    }
                case 2:
                    NavigationStack {
                        ChatRoomsView()
                    }
                case 3:
                    NavigationStack {
                        ProfileView(showCreateOrSignInView: $showCreateOrSignInView)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Button {
                        selectedTab = index
                    } label: {
//                        Image(systemName: getIcon(for: index) + (selectedTab == index ? ".fill" : ""))
                        Image(getIcon(for: index) + (selectedTab == index ? "_fill" : ""))
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(selectedTab == index ? .syncWhite : .syncGrey)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.bottom, 20)
            .frame(height: 80)
            .background(
                Color.syncWhite
            )
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.container)
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "syncc_home"
        case 1: return "syncc_thumbs_up"
        case 2: return "syncc_message_circle"
        case 3: return "syncc_user"
        default: return ""
        }
    }
    
    private func getLabel(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Likes"
        case 2: return "Chat"
        case 3: return "Profile"
        default: return ""
        }
    }
}
