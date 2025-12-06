import SwiftUI



struct ConnectionsView: View {
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @Binding var loadingViewFinishedLoading: Bool
    
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    
    @State private var selectedTab = 0
    let tabs = ["Discover", "Requests"]
    
    var body: some View {
        VStack {
            titleView()
            
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(tabs[index])
                                .font(.h2)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundStyle(selectedTab == index ? .black : .gray)
                            
                            // Indicator Bar
                            Rectangle()
                                .fill(selectedTab == index ? Color.black : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 5)
            
            if selectedTab == 0 {
                DiscoverView(showCreateOrSignInView: $showCreateOrSignInView,
                         loadingViewFinishedLoading: $loadingViewFinishedLoading)
                .environmentObject(profileModel)
                .environmentObject(subscriptionModel)
            } else if selectedTab == 1 {
                LikesReceivedView()
                    .environmentObject(profileModel)
                    .environmentObject(subscriptionModel)
            }
            
        }
        .padding(.horizontal, 10)
    }
    
    private func titleView() -> some View {
        HStack {
            Text("Connect")
            Spacer()
            
            if selectedTab == 0 {
                NavigationLink(
                    destination: FilterView(loadingViewFinishedLoading: $loadingViewFinishedLoading)
                        .environmentObject(profileModel)
                ) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
