
import SwiftUI

struct EditingFitnessTypesView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    var titleText: String
    @Binding var fitnessTypes: [FitnessType]
    
    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
    }
    
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "figure.run")
                    Text(titleText)
                }
                .titleModifiers()
                
                Text("You can choose up to 5!")
                    .bold()
                    .h2Style()
            }
            
            ZStack(alignment: .bottom) {
                DynamicGridView<FitnessType>(
                    isSubscriptionActive: true,
                    selectedItems: $fitnessTypes,
                    showPayWallView: .constant(false),
                    items: loadedFitnessTypes.sorted(by: { $0.name < $1.name })
                ) { type in
                    InterestPillView(
                        emoji: type.emoji,
                        name: type.name,
                        backgroundColour: fitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
                        foregroundColour: fitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
                    )
                }
                .animation(.easeIn, value: fitnessTypes.count)
                
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
            profileModel.user?.fitnessTypes = fitnessTypes
        }
    }
}
