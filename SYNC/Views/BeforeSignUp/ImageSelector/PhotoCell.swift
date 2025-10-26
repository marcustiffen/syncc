import SwiftUI



struct PhotoCell: View {
    let image: UIImage
    let index: Int
    @Binding var draggedIndex: Int?
    @Binding var selectedImages: [UIImage]
    let onRemove: (Int) -> Void
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.syncGreen, lineWidth: 2)
                )
                .onTapGesture {
                    onTap()
                }
                .onDrag {
                    draggedIndex = index
                    return NSItemProvider(object: String(index) as NSString)
                }
                .onDrop(of: [.text], delegate: OnBoardingPhotoDropDelegate(
                    destinationIndex: index,
                    draggedIndex: $draggedIndex,
                    items: $selectedImages
                ))

            Button {
                withAnimation {
                    onRemove(index)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.syncWhite)
                    .background(Color.syncGrey.clipShape(Circle()))
            }
            .padding(4)
        }
    }
}
