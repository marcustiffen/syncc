import SwiftUI
import UIKit
import SwiftfulUI

struct FitnessTypeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                            FitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                    .onTapGesture {
                        signUpModel.fitnessTypes = []
                    }
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "figure.run")
                    Text("Choose up to 5 workout preferences")
                }
                .titleModifiers()
                
                ZStack(alignment: .bottom) {
                    DynamicGridView<FitnessType>(isSubscriptionActive: true, selectedItems: $signUpModel.fitnessTypes, showPayWallView: .constant(false), items: loadedFitnessTypes.sorted(by: { $0.name < $1.name })) { type in
                        InterestPillView(
                            emoji: type.emoji,
                            name: type.name,
                            backgroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
                            foregroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
                        )
                    }
                    .animation(.easeIn, value: signUpModel.fitnessTypes.count)
                    
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
                        FitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}


//struct FitnessTypeView: View {
//    @Binding var showCreateOrSignInView: Bool
//    @Binding var isLoading: Bool
//    @Binding var loadingViewFinishedLoading: Bool
//    @EnvironmentObject var signUpModel: SignUpModel
//    
//    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
//        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
//    }
//    
//    @State private var showPayWallView = false
//    
//    var body: some View {
//            VStack(spacing: 20) {
//                HStack {
//                    SyncBackButton()
//                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        FitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
//                    .onTapGesture {
//                        signUpModel.fitnessTypes = []
//                    }
//                }
//                .padding(.bottom, 40)
//                
//                VStack(alignment: .leading, spacing: 10) {
//                    Image(systemName: "figure.run")
//                    Text("What are your workout preferences?")
//                }
//                .titleModifiers()
//                
//                ZStack(alignment: .bottom) {
//                    DynamicGridView<FitnessType>(
//                        isSubscriptionActive: true,
//                        selectedItems: $signUpModel.fitnessTypes,
//                        showPayWallView: $showPayWallView,
//                        items: loadedFitnessTypes.sorted(by: { $0.name < $1.name })
//                    ) { type in
//                        InterestPillView(
//                            emoji: type.emoji,
//                            name: type.name,
//                            backgroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
//                            foregroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
//                        )
//                    }
//                    .animation(.easeIn, value: signUpModel.fitnessTypes.count)
//                    
//                    Rectangle()
//                        .fill(
//                            LinearGradient(colors: [.syncWhite.opacity(0.0), .syncWhite], startPoint: .top, endPoint: .bottom)
//                        )
//                        .frame(height: 20)
//                        .allowsHitTesting(false)
//                }
//                .frame(maxHeight: .infinity)
////                Spacer(minLength: 70)
//                
//                HStack {
//                    Spacer()
//                    OnBoardingNavigationLink(text: "Next") {
//                        FitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
//                }
//            }
//        .navigationBarBackButtonHidden(true)
//        .onBoardingBackground()
//    }
//}
