import SwiftUI
import CoreLocation
import PhotosUI


struct EditProfileView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    let tabs = ["View", "Edit"]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 40)
            
            // Custom Tab Selector
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(tabs[index])
//                                .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
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
            .padding(.horizontal, 10)
            // Tab Content
            if selectedTab == 0 {
                ProfileCardView(user: profileModel.user, isCurrentUser: true, likeAction: {}, dislikeAction: {})
                    .padding(.top, 10)
            } else if selectedTab == 1 {
                EditView()
                    .padding(.top, 10)
            }
        }
        .padding([.horizontal, .top], 10)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.container)
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton { dismiss() }
            Spacer()
            Text("Profile")
                .h1Style()
            
            Spacer()
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
}
