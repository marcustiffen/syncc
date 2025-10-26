import SwiftUI


struct PhysicalInfoSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var isEditingWeight = false
    let fitnessLevels = ["Beginner", "Casual", "Active", "Intermediate", "Enthusiast", "Advanced", "Athlete", "Elite", "Any"]
    
    var body: some View {
        VStack {
            // Height Picker
            HeightPicker(profileModel: profileModel)
            
            // Weight Editor
            WeightEditor(profileModel: profileModel, isEditingWeight: $isEditingWeight)
            
            // Fitness Level Picker
            FitnessLevelPicker(profileModel: profileModel, fitnessLevels: fitnessLevels)
        }
    }
}
