import SwiftUI

struct BioSection: View {
    @ObservedObject var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Bio")
                .h2Style()
            
            CustomTextEditor(text: Binding(
                get: { profileModel.user?.bio ?? "" },
                set: { profileModel.user?.bio = $0 }
            ), placeholder: "Type here...")

        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
        .background(SectionDivider())
    }
}
