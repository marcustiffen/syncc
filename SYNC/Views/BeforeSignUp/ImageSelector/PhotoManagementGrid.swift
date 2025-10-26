import SwiftUI
import PhotosUI


struct PhotoManagementGrid: View {
    @Binding var selectedImages: [UIImage]
    @Binding var pickerItems: [PhotosPickerItem]
    var maxImageCount: Int
    var onImageRemoved: ((Int) -> Void)?
    var onImagesReordered: (([UIImage]) -> Void)?
    var onImageSelected: ((Int) -> Void)?
    
    @State private var draggedIndex: Int? = nil
    @State private var loadingImages = [UIImage]()
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(selectedImages.indices, id: \.self) { index in
                PhotoCell(
                    image: selectedImages[index],
                    index: index,
                    draggedIndex: $draggedIndex,
                    selectedImages: $selectedImages,
                    onRemove: { index in
                        onImageRemoved?(index)
                    },
                    onTap: {
                        withAnimation {
                            onImageSelected?(index)
                        }
                    }
                )
            }
            
            ForEach(loadingImages.indices, id: \.self) { _ in
                LoadingPlaceholder()
            }

            if selectedImages.count + loadingImages.count < maxImageCount {
                AddPhotoButton(
                    maxSelectionCount: maxImageCount - selectedImages.count - loadingImages.count,
                    pickerItems: $pickerItems
                )
            }
        }
        .animation(.easeInOut, value: selectedImages)
        .onChange(of: selectedImages) { _, newImages in
            onImagesReordered?(newImages)
        }
    }
}
