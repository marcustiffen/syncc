import SwiftUI

struct BioSection: View {
    @ObservedObject var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Your Bio")
                .h2Style()
            
//            TextField("", text: Binding(
//                get: { profileModel.user?.bio ?? "" },
//                set: { profileModel.user?.bio = $0 }
//            ), prompt: Text("Type here...").font(.h2).foregroundStyle(.syncGrey))
//            .bodyTextStyle()
            CustomTextEditor(text: Binding(
                get: { profileModel.user?.bio ?? "" },
                set: { profileModel.user?.bio = $0 }
            ), placeholder: "Type here...")
//            .padding(.leading, -3)
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
        .background(SectionDivider())
    }
}
