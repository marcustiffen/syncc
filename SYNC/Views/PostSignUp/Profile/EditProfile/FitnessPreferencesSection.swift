import SwiftUI


struct FitnessPreferencesSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var showEditingFitnessTypes = false
    @State private var showEditingFitnessGoals = false
    
    let userManager: DBUserManager
    
    var body: some View {
        VStack {
            // Workout Preferences
            PreferenceButton(
                title: "Edit your workout preferences",
                isShowingSheet: $showEditingFitnessTypes
            ) {
                EditingFitnessTypesView(
                    titleText: "Edit your workout preferences",
                    fitnessTypes: Binding(
                        get: { profileModel.user?.fitnessTypes ?? [] },
                        set: { profileModel.user?.fitnessTypes = $0 }
                    ),
                    isPresented: $showEditingFitnessTypes, userManager: userManager
                )
            }
            
            // Fitness Goals
            PreferenceButton(
                title: "Edit your fitness goals",
                isShowingSheet: $showEditingFitnessGoals
            ) {
                EditingFitnessGoalsView(
                    titleText: "Edit your fitness goals",
                    fitnessGoals: Binding(
                        get: { profileModel.user?.fitnessGoals ?? [] },
                        set: { profileModel.user?.fitnessGoals = $0 }
                    ),
                    isPresented: $showEditingFitnessGoals, userManager: userManager
                )
            }
        }
    }
}
