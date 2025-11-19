import SwiftUI



struct TabbarView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @State private var selectedTab = 0
    @Binding var loadingViewFinishedLoading: Bool
    
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var chatRoomsManager: ChatRoomsManager
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    
    
    @State private var showCreateActivitySheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content Area
                switch selectedTab {
                case 0:
                    ActivityView()
                        .environmentObject(profileModel)
                        .environmentObject(chatRoomsManager)
                        .environmentObject(subscriptionModel)
                case 1:
                    ConnectionsView(
                        loadingViewFinishedLoading: $loadingViewFinishedLoading,
                        showCreateOrSignInView: $showCreateOrSignInView,
                        isLoading: $isLoading
                    )
                    .environmentObject(profileModel)
                    .environmentObject(chatRoomsManager)
                    .environmentObject(subscriptionModel)
                                        
                case 3:
                    ChatRoomsView()
                        .environmentObject(profileModel)
                        .environmentObject(chatRoomsManager)
                        .environmentObject(subscriptionModel)
                case 4:
                    EditProfileView(showCreateOrSignInView: $showCreateOrSignInView)
                        .environmentObject(profileModel)
                        .environmentObject(chatRoomsManager)
                        .environmentObject(subscriptionModel)
                default:
                    EmptyView()
                }

                Spacer()

                HStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        if index == 2 {
                            Button {
                                showCreateActivitySheet.toggle()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.syncGreen)
                                        .frame(width: 60, height: 60)
                                        .shadow(radius: 5)

                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .font(.system(size: 28, weight: .bold))
                                }
                                .offset(y: -5)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button {
                                selectedTab = index
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    if index == 1 {
                                        Image(systemName: "person.2" + (selectedTab == index ? ".fill" : ""))
                                            .foregroundStyle(.black)
                                            .font(.system(size: 24))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                    } else {
                                        Image(getIcon(for: index) + (selectedTab == index ? "_fill" : ""))
                                            .font(.system(size: 24))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                    }

                                    // Badge for Chat tab
                                    if index == 3 && chatRoomsManager.totalUnreadMessages > 0 {
                                        ZStack {
                                            Circle()
                                                .fill(Color.syncGreen)
                                                .frame(width: 20, height: 20)

                                            Text("\(min(chatRoomsManager.totalUnreadMessages, 99))")
                                                .bodyTextStyle()
                                                .foregroundColor(.black)
                                                .minimumScaleFactor(0.8)
                                        }
                                        .offset(x: -20, y: 0)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                .frame(height: 80)
                .background(Color.syncWhite)
                .sheet(isPresented: $showCreateActivitySheet) {
                    NavigationStack {
                        CreateActivityView(profileModel: profileModel)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea(.container)
        }
    }

    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "Syncc_home"
        case 1: return "" // <-- new icon for Friends
        case 2: return "Syncc_thumbs_up"
        case 3: return "Syncc_message_circle"
        case 4: return "Syncc_user"
        default: return ""
        }
    }
    
    private func getLabel(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Friends"
        case 2: return "Likes"
        case 3: return "Chat"
        case 4: return "Profile"
        default: return ""
        }
    }
}
