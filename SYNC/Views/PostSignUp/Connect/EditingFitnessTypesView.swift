
import SwiftUI

struct EditingFitnessTypesView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    var titleText: String
    @Binding var fitnessTypes: [String]
    
    @State private var loadedFitnessTypes: [String] = StandardFitnessType.allCases.map(\.rawValue)
    
    @Binding var isPresented: Bool
    
    let userManager: DBUserManager
    
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
                DynamicGridView<String>(
                    isSubscriptionActive: true,
                    selectedItems: $fitnessTypes,
                    showPayWallView: .constant(false),
                    items: loadedFitnessTypes.sorted(by: { $0 < $1 })
                ) { type in
                    InterestPillView(
                        emoji: FitnessTypeHelper.emoji(for: type),
                        name: type,
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
            .frame(height: 400)
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .background(
            Color.white
                .ignoresSafeArea()
        )
        .onDisappear {
            profileModel.user?.filteredFitnessTypes = fitnessTypes
        }
        .padding(.horizontal, 30)
        .navigationBarBackButtonHidden(true)
    }
}
