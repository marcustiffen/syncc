import SwiftUI
import PhotosUI


struct PhotoManagementView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var loadingImages = [UIImage]()
    @State private var draggedPhoto: DBImage? = nil
    @State private var editingImageIndex: Int? = nil
    
    private let maxImageCount = 6
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 45), count: 3)

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20) {
                // Existing images - Simplified approach
                if let images = profileModel.user?.images {
                    ForEach(0..<images.count, id: \.self) { index in
                        let image = images[index]
                        photoItemView(image: image, index: index)
                    }
                }

                // Loading placeholders
                ForEach(loadingImages, id: \.self) { _ in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                        ProgressView()
                    }
                }

                // Add PhotosPicker if space available
                if (profileModel.user?.images?.count ?? 0) + loadingImages.count < maxImageCount {
                    photoPickerView
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
        }
        .onChange(of: pickerItems) { _, newItems in
            Task {
                await handlePhotoSelection(items: newItems)
            }
        }
        .fullScreenCover(item: Binding(
            get: {
                if let index = editingImageIndex {
                    return index
                }
                return nil
            },
            set: { editingImageIndex = $0 }
        )) { index in
            imageEditorView(for: index)
        }
    }
    
    // MARK: - Extracted Views
    
    private func photoItemView(image: DBImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if image.uiImage != UIImage() {
                Image(uiImage: image.uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ImageLoaderView(urlString: image.url)
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.syncGreen, lineWidth: 2)
                .frame(width: 100, height: 100)

            Button {
                withAnimation {
                    deletePhoto(image: image)
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.syncWhite)
                    .background(Color.syncGrey.clipShape(Circle()))
            }
            .padding(4)
        }
        .frame(width: 100, height: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            editingImageIndex = index
        }
        .onDrag {
            draggedPhoto = image
            return NSItemProvider(object: image.url as NSString)
        }
        .onDrop(of: [.text], delegate: createDropDelegate(for: image))
    }
    
    private var photoPickerView: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: maxImageCount - (profileModel.user?.images?.count ?? 0) - loadingImages.count,
            matching: .images
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.syncGreen)
            }
        }
    }
    
    private func imageEditorView(for index: Int) -> some View {
        NavigationStack {
            ImageEditorView(
                imageBeingEdited: Binding(
                    get: {
                        guard let images = profileModel.user?.images, index < images.count else {
                            return DBImage(url: "", uiImage: UIImage(), offsetX: .zero, offsetY: .zero, scale: 1.0)
                        }
                        return images[index]
                    },
                    set: {
                        if var images = profileModel.user?.images, index < images.count {
                            images[index] = $0
                            profileModel.user?.images = images
                        }
                    }
                ),
                onSave: {
                    Task {
                        try? await updatePhotoData(index: index)
                    }
                }
            )
            .environmentObject(profileModel)
            .navigationBarItems(
                leading: Button("Cancel") {
                    editingImageIndex = nil
                }
            )
        }
    }

    // MARK: - Helper Functions
    
    private func handlePhotoSelection(items: [PhotosPickerItem]) async {
        var newImages = [UIImage]()

        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    loadingImages.append(uiImage)
                }
                newImages.append(uiImage)
            }
        }

        if let userId = profileModel.user?.uid {
            let urls = await DBUserManager.shared.uploadPhoto(selectedImages: newImages, uid: userId)

            DispatchQueue.main.async {
                var currentImages = profileModel.user?.images ?? []

                for (i, url) in urls.enumerated() {
                    let dbImage = DBImage(url: url, uiImage: newImages[i], offsetX: .zero, offsetY: .zero, scale: 1.0)
                    currentImages.append(dbImage)
                }

                profileModel.user?.images = currentImages
                loadingImages.removeAll()
                pickerItems.removeAll()
            }
        }
    }

    private func deletePhoto(image: DBImage) {
        guard var currentImages = profileModel.user?.images else { return }
        currentImages.removeAll(where: { $0 == image })

        Task {
            var updatedUser = profileModel.user
            updatedUser?.images = currentImages

            DispatchQueue.main.async {
                profileModel.user = updatedUser
            }

            if let user = updatedUser {
                do {
                    try await DBUserManager.shared.updateUser(user)
                    try await DBUserManager.shared.deletePhoto(url: image.url)
                } catch {
                    print("Error deleting photo: \(error.localizedDescription)")
                }
            }
        }
    }

    private func createDropDelegate(for image: DBImage) -> DropDelegate {
        PhotoDropDelegateDBImage(
            item: image,
            items: profileModel.user?.images ?? [],
            completion: { draggedItem, destination in
                reorderPhotos(draggedItem: draggedItem, destination: destination)
            }
        )
    }

    private func reorderPhotos(draggedItem: DBImage, destination: Int) {
        guard var updatedUser = profileModel.user,
              var images = updatedUser.images,
              let currentIndex = images.firstIndex(of: draggedItem) else { return }

        images.remove(at: currentIndex)
        images.insert(draggedItem, at: destination)

        updatedUser.images = images
        profileModel.user = updatedUser

        Task {
            try? await DBUserManager.shared.updateUser(updatedUser)
        }
    }
    
    private func updatePhotoData(index: Int) async throws {
        if let image = profileModel.user?.images?[index] {
            try await DBUserManager.shared.updateImageData(userId: profileModel.user?.uid ?? "", updatedImage: image)
        }
    }
}
