import SwiftUI


struct WeightEditor: View {
    @ObservedObject var profileModel: ProfileModel
    @Binding var isEditingWeight: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Weight")
            
            Spacer()
            Button(action: { isEditingWeight = true }) {
                Text("\(String(format: "%.1f", profileModel.user?.weight ?? 0.0)) kg")
                    .foregroundStyle(.syncBlack)

            }
        }
        .h2Style()
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
        .background(SectionDivider())
        .sheet(isPresented: $isEditingWeight) {
            EditWeightView(
                weight: Binding(
                    get: { profileModel.user?.weight ?? 0.0 },
                    set: { profileModel.user?.weight = $0 }
                ),
                isPresented: $isEditingWeight
            )
        }
    }
}
