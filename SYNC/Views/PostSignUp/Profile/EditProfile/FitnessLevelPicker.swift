import SwiftUI


struct FitnessLevelPicker: View {
    @ObservedObject var profileModel: ProfileModel
    let fitnessLevels: [String]
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Edit Your Fitness Level")
//                .bold()
                .h2Style()
            Spacer()
//            Picker("Fitness Level", selection: Binding(
//                get: { profileModel.user?.fitnessLevel ?? fitnessLevels.first ?? "Any" },
//                set: { profileModel.user?.fitnessLevel = $0 }
//            )) {
//                ForEach(fitnessLevels, id: \.self) { level in
//                    Text(level).bodyTextStyle().tag(level)
//                }
//            }
//            .accentColor(.syncBlack)
            
            Menu {
                Picker(selection: Binding(
                    get: { profileModel.user?.fitnessLevel ?? fitnessLevels.first ?? "Any" },
                    set: { profileModel.user?.fitnessLevel = $0 }
                )) {
                    ForEach(fitnessLevels, id: \.self) { level in
                        Text(level).bodyTextStyle().tag(level)
                    }
                } label: {}
            } label: {
                Text("\(profileModel.user?.fitnessLevel ?? "")")
                    .h2Style()
            }
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
//        .padding(.trailing, -14)
        .background(SectionDivider())
    }
}
