import FirebaseAuth
import FirebaseStorage
import SwiftUI
import PhotosUI



struct AddPhotoButton: View {
    let maxSelectionCount: Int
    @Binding var pickerItems: [PhotosPickerItem]
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: maxSelectionCount,
            matching: .images
        ) {
            VStack {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.syncBlack)
                
                Text("Add Photo")
                    .bodyTextStyle()
                    .foregroundStyle(.syncBlack)
            }
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
        }
        .transition(.scale(scale: 0.8))
    }
}
