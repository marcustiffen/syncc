import SwiftUI


//struct FilteredFitnessTypeView: View {
//    @Binding var showCreateOrSignInView: Bool
//    @Binding var isLoading: Bool
//    @Binding var loadingViewFinishedLoading: Bool
//    @EnvironmentObject var signUpModel: SignUpModel
//    @EnvironmentObject var subscriptionModel : SubscriptionModel
//    
//    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
//        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
//    }
//    
//    @State private var showPayWallView = false
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 20) {
//                HStack {
//                    SyncBackButton()
//                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                            FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
//                    .onTapGesture {
//                        signUpModel.filteredFitnessTypes = []
//                    }
//                }
//                .padding(.bottom, 40)
//                
//                
//                VStack(alignment: .leading) {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Image(systemName: "sportscourt")
//                        Text("Which fitness types would you like to see from people?")
//                    }
//                    .titleModifiers()
//                    
//                    Text("NOTE: ")
//                        .bold()
//                        .h2Style()
//                    
//                    Text("This is a premium feature!")
//                        .bodyTextStyle()
//                        .multilineTextAlignment(.leading)
//                        .foregroundStyle(.syncGrey)
//                        .lineLimit(nil)
//                        .fixedSize(horizontal: false, vertical: true)
//                    
//                    OnBoardingButton(text: "Upgrade here") {
//                        showPayWallView = true
//                    }
//                }
//                
//                ZStack(alignment: .bottom) {
//                    DynamicGridView<FitnessType>(selectedItems: $signUpModel.filteredFitnessTypes, showPayWallView: $showPayWallView, items: loadedFitnessTypes.sorted(by: { $0.name < $1.name })) { type in
//                        InterestPillView(
//                            emoji: type.emoji,
//                            name: type.name,
//                            backgroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
//                            foregroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
//                        )
//                    }
//                    .animation(.easeIn, value: signUpModel.filteredFitnessTypes.count)
//                    
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: [.syncWhite.opacity(0.0), .syncWhite], startPoint: .top, endPoint: .bottom)
//                        )
//                        .frame(height: 20)
//                        .allowsHitTesting(false)
//                }
//                
//                Spacer(minLength: 70)
//                
//            }
//            VStack {
//                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
////                    NavigationStack {
//                        FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
////                    }
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .onBoardingBackground()
//    }
//}


struct FilteredFitnessTypeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
    }
    
    @State private var showPayWallView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                        FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                    .onTapGesture {
                        signUpModel.filteredFitnessTypes = []
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "sportscourt")
                        Text("Filter from up to 5 workout preferences!")
                    }
                    .titleModifiers()
                    
                    if !subscriptionModel.isSubscriptionActive {
                    Text("NOTE: ")
                        .bold()
                        .h2Style()
                    
                        Text("This is a premium feature!")
                            .bodyTextStyle()
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.syncGrey)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        OnBoardingButton(text: "Upgrade to Premium") {
                            showPayWallView = true
                        }
                    }
                }
                
                ZStack(alignment: .bottom) {
                    // Use subscription model's active status for FilteredFitnessTypeView
                    DynamicGridView<FitnessType>(
                        isSubscriptionActive: subscriptionModel.isSubscriptionActive,
                        selectedItems: $signUpModel.filteredFitnessTypes,
                        showPayWallView: $showPayWallView,
                        items: loadedFitnessTypes.sorted(by: { $0.name < $1.name })
                    ) { type in
                        InterestPillView(
                            emoji: type.emoji,
                            name: type.name,
                            backgroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
                            foregroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
                        )
                    }
                    .animation(.easeIn, value: signUpModel.filteredFitnessTypes.count)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.syncWhite.opacity(0.0), .syncWhite], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 20)
                        .allowsHitTesting(false)
                }
                
                Spacer(minLength: 70)
                
                
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
                        FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .sheet(isPresented: $showPayWallView) {
            PayWallView(isPaywallPresented: $showPayWallView)
        }
    }
}

