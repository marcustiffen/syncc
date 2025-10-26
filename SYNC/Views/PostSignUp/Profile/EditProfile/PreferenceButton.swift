import SwiftUI


struct PreferenceButton<Sheet: View>: View {
    let title: String
    @Binding var isShowingSheet: Bool
    let sheetContent: () -> Sheet
    
    var body: some View {
        HStack {
            Button(action: { isShowingSheet = true }) {
                Text(title)
//                    .bold()
                    
                Spacer()
                Image(systemName: "chevron.down")
            }
            .h2Style()
            .foregroundStyle(.syncBlack)
        }
        .padding(.vertical, 20)
        .background(SectionDivider())
        .sheet(isPresented: $isShowingSheet) {
            sheetContent()
        }
    }
}
