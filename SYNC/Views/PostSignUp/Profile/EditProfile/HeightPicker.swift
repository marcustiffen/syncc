import SwiftUI


struct HeightPicker: View {
    @ObservedObject var profileModel: ProfileModel
    
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Edit Your Height")
                .h2Style()
            
            Spacer()
            
            Menu {
                Picker(selection: Binding(
                    get: { profileModel.user?.height ?? 0 },
                    set: { profileModel.user?.height = $0 }
                )) {
                    ForEach(0...210, id: \.self) { height in
                        Text("\(height) cm").tag(height)
                    }
                } label: {}
            } label: {
                Text("\(profileModel.user?.height ?? 0) cm")
                    .h2Style()
            }
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
        .background(SectionDivider())
    }
}
