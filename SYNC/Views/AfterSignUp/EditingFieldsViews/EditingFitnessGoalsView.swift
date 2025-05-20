
import SwiftUI

struct EditingFitnessGoalsView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    var titleText: String
    @Binding var fitnessGoals: [FitnessGoal]
    
    @Binding var isPresented: Bool
    
    @State private var loadedFitnessGoals: [FitnessGoal] = StandardFitnessGoal.allCases.map {
        FitnessGoal(id: $0.id, goal: $0.rawValue, emoji: $0.emoji)
    }
    
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
                        ForEach(loadedFitnessGoals.sorted(by: { $0.goal < $1.goal })) { type in
                            InterestPillView(
                                emoji: type.emoji,
                                name: type.goal,
                                backgroundColour: fitnessGoals.contains(type) ? Color.syncGreen : Color.syncGrey,
                                foregroundColour: fitnessGoals.contains(type) ? Color.syncBlack : Color.syncWhite
                            )
                            .onTapGesture {
//                                if subscriptionModel.isSubscriptionActive {
                                if fitnessGoals.contains(type) && fitnessGoals.count < 5 {
                                        fitnessGoals.removeAll { $0 == type }
                                    } else {
                                        fitnessGoals.append(type)
                                    }
//                                }
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
            profileModel.user?.fitnessGoals = fitnessGoals
        }
    }
}
