import FirebaseAuth
import FirebaseStorage
import SwiftUI
import PhotosUI



struct ImageSelectorView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var dbImages = [DBImage]()
    
    @State private var showAlert = false
    @State private var editingImageIndex: Int? = nil
    @State private var currentOffset = CGSize.zero
    @State private var currentScale: CGFloat = 0.1
    
    private let maxImageCount = 6
    
    var body: some View {
        ZStack {
            // Main content
            if editingImageIndex == nil {
                normalViewContent
                    .onBoardingBackground()
            } else {
                imageEditorContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        Color.white
                            .ignoresSafeArea()
                    )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: pickerItems) { _, _ in
            Task {
                for item in pickerItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data),
                       selectedImages.count < maxImageCount {
                        selectedImages.append(uiImage)
                        
                        // Create a new DBImage with default positioning
                        let newDBImage = DBImage(
                            url: "", // Will be updated after Firebase upload
                            uiImage: uiImage,
                            offsetX: .zero,
                            offsetY: .zero,
                            scale: 1.0
                        )
                        
                        dbImages.append(newDBImage)
                    }
                }
                // Clear the picker items after processing
                pickerItems = []
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("Okay") { }
        } message: {
            Text("You must select at least one image!")
        }
    }
    
    // MARK: - Normal View Content
    private var normalViewContent: some View {
        VStack(spacing: 40) {
            HStack {
                SyncBackButton()
                Spacer()
                OnBoardingNavigationLinkSkip {
                    FitnessProfileConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                }
                .onTapGesture {
                    signUpModel.images = []
                }
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "photo.artframe")
                Text("Add up to 6 photos of yourself!")
            }
            .titleModifiers()
            
            PhotoManagementGrid(
                selectedImages: $selectedImages,
                pickerItems: $pickerItems,
                maxImageCount: maxImageCount,
                onImageRemoved: { index in
                    selectedImages.remove(at: index)
                    dbImages.remove(at: index)
                },
                onImagesReordered: { newImages in
                    // Reorder dbImages to match the new order of selectedImages
                    let newDBImages = newImages.compactMap { newImage in
                        // Find the matching DBImage for each reordered UIImage
                        return selectedImages.enumerated().compactMap { (i, oldImage) -> DBImage? in
                            if newImage === oldImage, i < dbImages.count {
                                return dbImages[i]
                            }
                            return nil
                        }.first
                    }
                    
                    selectedImages = newImages
                    if newDBImages.count == newImages.count {
                        dbImages = newDBImages
                    }
                    signUpModel.images = dbImages
                },
                onImageSelected: { index in
                    // Set up the editor with the current image's position and scale
                    if index < dbImages.count {
                        editingImageIndex = index
                        currentOffset = CGSize(
                            width: dbImages[index].offsetX.width,
                            height: dbImages[index].offsetY.height
                        )
                        currentScale = dbImages[index].scale
                    }
                }
            )
            
            if !selectedImages.isEmpty {
                Text("Tap an image to adjust its position")
                    .bodyTextStyle()
                    .foregroundStyle(.syncGrey)
                    .padding(.top, 5)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                OnBoardingNavigationLink(text: "Next") {
                    FitnessProfileConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                }
                .onTapGesture {
                    if selectedImages.count == 0 {
                        showAlert = true
                    } else {
                        // Update the signUpModel with our DBImage array before proceeding
                        signUpModel.images = dbImages
                    }
                }
            }
        }
    }
    
    // MARK: - Image Editor Content
//    private var imageEditorContent: some View {
//        VStack(alignment: .center, spacing: 0) {
//            // Image editor area
//            GeometryReader { geo in
//                let screenWidth = geo.size.width // Subtract padding (20 on each side)
//                let screenHeight = geo.size.width * 1.2
//                
//                ZStack(alignment: .center) {
//                    if let index = editingImageIndex, index < selectedImages.count {
//                        // Full-screen image (darkened outside the crop area)
//                        Image(uiImage: selectedImages[index])
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: screenWidth, height: screenHeight)
//                            .offset(currentOffset)
//                            .scaleEffect(currentScale)
//                            .overlay(
//                                // Dark overlay with transparent "window"
//                                ZStack {
//                                    // Fully dark background
//                                    Color.black.opacity(0.7)
//                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
////                                        .frame(width: geo.size.width, height: geo.size.height)
//                                    
//                                    // Transparent "window"
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .frame(width: screenWidth, height: screenHeight)
//                                        .blendMode(.destinationOut)
//                                }
//                                .compositingGroup()
//                            )
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        self.currentOffset = CGSize(
//                                            width: value.translation.width + dbImages[index].offsetX.width,
//                                            height: value.translation.height + dbImages[index].offsetY.height
//                                        )
//                                    }
//                                    .onEnded { value in
//                                        // Store the final offset when drag ends
//                                        self.currentOffset = CGSize(
//                                            width: value.translation.width + dbImages[index].offsetX.width,
//                                            height: value.translation.height + dbImages[index].offsetY.height
//                                        )
//                                        dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
//                                        dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
//                                        dbImages[index].scale = currentScale
//                                        signUpModel.images = dbImages
//                                    }
//                            )
//                            .gesture(
//                                MagnificationGesture()
//                                    .onChanged { value in
//                                        let scaleFactor = dbImages[index].scale * value
//                                        self.currentScale = scaleFactor
//                                    }
//                                    .onEnded { value in
//                                        let scaleFactor = dbImages[index].scale * value
//                                        self.currentScale = scaleFactor
//                                        dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
//                                        dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
//                                        dbImages[index].scale = currentScale
//                                        signUpModel.images = dbImages
//                                    }
//                            )
//                        
//                        // Border for the crop window
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.white, lineWidth: 2)
//                            .frame(width: screenWidth, height: screenHeight)
//                            .allowsHitTesting(false)
//                        
//                        // Add help text at the bottom
//                        VStack {
//                            Spacer()
//                            Text("Pinch to zoom • Drag to position")
//                                .bodyTextStyle()
//                                .foregroundStyle(.syncWhite)
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 12)
//                                .background(Color.black.opacity(0.5))
//                                .cornerRadius(8)
//                                .padding(.bottom, 30)
//                        }
//                    }
//                }
//                .frame(width: geo.size.width, height: geo.size.height)
//                .position(x: geo.size.width / 2, y: geo.size.height / 2)
//            }
//            
//                        
//            // Bottom action buttons
//            HStack(spacing: 20) {
//                Button {
//                    withAnimation {
//                        editingImageIndex = nil
//                    }
//                } label: {
//                    Text("Cancel")
//                        .h2Style()
//                        .foregroundStyle(.syncBlack)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 15)
//                        .background(Color.syncGrey)
//                        .cornerRadius(10)
//                }
//                
//                Button {
//                    withAnimation {
//                        if let index = editingImageIndex, index < dbImages.count {
//                            dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
//                            dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
//                            dbImages[index].scale = currentScale
//                            signUpModel.images = dbImages
//                            editingImageIndex = nil
//                        }
//                    }
//                } label: {
//                    Text("Save")
//                        .h2Style()
//                        .foregroundStyle(.syncBlack)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 15)
//                        .background(Color.syncGreen)
//                        .cornerRadius(10)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 10)
//            .padding(.bottom, 30)
//            .background(Color.white)
//        }
//        .padding(.horizontal, 10)
//        .onAppear {
//            if let index = editingImageIndex, index < dbImages.count {
//                // Initialize with current values when the editor appears
//                currentOffset = CGSize(
//                    width: dbImages[index].offsetX.width,
//                    height: dbImages[index].offsetY.height
//                )
//                currentScale = dbImages[index].scale
//            }
//        }
//        .background(Color.black.opacity(0.3))
//    }
    
    private var imageEditorContent: some View {
        ZStack {
            // Full screen black background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                // Image editor area
                GeometryReader { geo in
                    let screenWidth = geo.size.width // Subtract padding (20 on each side)
                    let screenHeight = geo.size.width * 1.2
                    
                    ZStack(alignment: .center) {
                        if let index = editingImageIndex, index < selectedImages.count {
                            // Full-screen image
//                            Image(uiImage: selectedImages[index])
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: screenWidth, height: screenHeight)
//                                .offset(currentOffset)
//                                .scaleEffect(currentScale)
//                                .clipShape(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .frame(width: screenWidth, height: screenHeight)
//                                )
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: screenWidth, height: screenHeight)
                                .offset(currentOffset)
                                .scaleEffect(currentScale)
                                .overlay(
                                    // Dark overlay with transparent "window"
                                    ZStack {
                                        // Transparent "window"
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: screenWidth, height: screenHeight)
                                            .blendMode(.destinationOut)
                                    }
                                    .compositingGroup()
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            self.currentOffset = CGSize(
                                                width: value.translation.width + dbImages[index].offsetX.width,
                                                height: value.translation.height + dbImages[index].offsetY.height
                                            )
                                        }
                                        .onEnded { value in
                                            // Store the final offset when drag ends
                                            self.currentOffset = CGSize(
                                                width: value.translation.width + dbImages[index].offsetX.width,
                                                height: value.translation.height + dbImages[index].offsetY.height
                                            )
                                            dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
                                            dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
                                            dbImages[index].scale = currentScale
                                            signUpModel.images = dbImages
                                        }
                                )
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let scaleFactor = dbImages[index].scale * value
                                            self.currentScale = scaleFactor
                                        }
                                        .onEnded { value in
                                            let scaleFactor = dbImages[index].scale * value
                                            self.currentScale = scaleFactor
                                            dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
                                            dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
                                            dbImages[index].scale = currentScale
                                            signUpModel.images = dbImages
                                        }
                                )
                            
                            // Border for the crop window
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: screenWidth, height: screenHeight)
                                .allowsHitTesting(false)
                            
                            // Add help text at the bottom
                            VStack {
                                Spacer()
                                Text("Pinch to zoom • Drag to position")
                                    .bodyTextStyle()
                                    .foregroundStyle(.syncWhite)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(8)
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                
                // Bottom action buttons
                HStack(spacing: 20) {
                    Button {
                        withAnimation {
                            editingImageIndex = nil
                        }
                    } label: {
                        Text("Cancel")
                            .h2Style()
                            .foregroundStyle(.syncBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.syncGrey)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        withAnimation {
                            if let index = editingImageIndex, index < dbImages.count {
                                dbImages[index].offsetX = CGSize(width: currentOffset.width, height: 0)
                                dbImages[index].offsetY = CGSize(width: 0, height: currentOffset.height)
                                dbImages[index].scale = currentScale
                                signUpModel.images = dbImages
                                editingImageIndex = nil
                            }
                        }
                    } label: {
                        Text("Save")
                            .h2Style()
                            .foregroundStyle(.syncBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.syncGreen)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 10)
            .onAppear {
                if let index = editingImageIndex, index < dbImages.count {
                    // Initialize with current values when the editor appears
                    currentOffset = CGSize(
                        width: dbImages[index].offsetX.width,
                        height: dbImages[index].offsetY.height
                    )
                    currentScale = dbImages[index].scale
                }
            }
        }
    }
}

// Updated PhotoManagementGrid
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

// Updated PhotoCell with tap action
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


// Loading placeholder component
struct LoadingPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.syncGrey)
                .frame(width: 100, height: 100)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .transition(.scale(scale: 0.8))
    }
}

// Add photo button component
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

struct OnBoardingPhotoDropDelegate: DropDelegate {
    let destinationIndex: Int
    @Binding var draggedIndex: Int?
    @Binding var items: [UIImage]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedIndex = self.draggedIndex else { return false }
        
        withAnimation {
            let draggedItem = items[draggedIndex]
            items.remove(at: draggedIndex)
            items.insert(draggedItem, at: destinationIndex)
        }
        
        self.draggedIndex = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
