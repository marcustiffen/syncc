
import SwiftUI

struct EditingFitnessGoalsView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    var titleText: String
    @Binding var fitnessGoals: [String]
    
    @Binding var isPresented: Bool
    
    @State private var loadedFitnessGoals: [String] = StandardFitnessGoal.allCases.map(\.rawValue)
    
    let userManager: DBUserManager
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "dumbbell")
                    Text(titleText)
                }
                .titleModifiers()
                
                Text("You can choose up to 5!")
                    .bold()
                    .h2Style()
            }
            
            
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(loadedFitnessGoals.sorted(by: { $0 < $1 })) { type in
                            InterestPillView(
                                emoji: FitnessGoalHelper.emoji(for: type),
                                name: type,
                                backgroundColour: fitnessGoals.contains(type) ? Color.syncGreen : Color.syncGrey,
                                foregroundColour: fitnessGoals.contains(type) ? Color.syncBlack : Color.syncWhite
                            )
                            .onTapGesture {
                                if fitnessGoals.contains(type) {
                                    fitnessGoals.removeAll { $0 == type }
                                } else {
                                    if fitnessGoals.count < 5 {
                                        fitnessGoals.append(type)
                                    }
                                }
                            }
                        }
                    }
                    .animation(.easeIn, value: fitnessGoals.count)
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(colors: [.syncWhite.opacity(0.0), .syncWhite], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: 20)
                    .allowsHitTesting(false)
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.white
                .ignoresSafeArea()
        )
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            profileModel.user?.filteredFitnessGoals = fitnessGoals
        }
    }
}
