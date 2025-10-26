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
    @State private var isLoadingImages = false
    
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
        .onAppear {
            Task {
                await loadExistingImages()
            }
        }
        .onChange(of: pickerItems) { _, _ in
            Task {
                await processNewImages()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("Okay") { }
        } message: {
            Text("You must select at least one image!")
        }
    }
    
    // MARK: - Load Existing Images
    private func loadExistingImages() async {
        guard !signUpModel.images.isEmpty else { return }
        
        isLoadingImages = true
        
        // Load images from URLs
        for dbImage in signUpModel.images {
            if !dbImage.url.isEmpty {
                if let uiImage = await loadImageFromURL(dbImage.url) {
                    selectedImages.append(uiImage)
                    
                    // Create new DBImage with loaded UIImage
                    let newDBImage = DBImage(
                        url: dbImage.url,
                        uiImage: uiImage,
                        offsetX: dbImage.offsetX,
                        offsetY: dbImage.offsetY,
                        scale: dbImage.scale
                    )
                    dbImages.append(newDBImage)
                }
            }
        }
        
        // Update the sign up model with loaded images
        signUpModel.images = dbImages
        isLoadingImages = false
    }
    
    // MARK: - Load Image from URL
    private func loadImageFromURL(_ urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("❌ Error loading image from URL: \(error)")
            return nil
        }
    }
    
    // MARK: - Process New Images
    private func processNewImages() async {
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
    
    // MARK: - Normal View Content
    private var normalViewContent: some View {
        VStack(spacing: 40) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .bio
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .bio)
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "photo.artframe")
                    Text("Add up to 6 photos of yourself!")
                }
                .titleModifiers()
                
                Text("NOTE: ")
                    .h2Style()
                    .bold()
                Text("You must select at least one image.")
                    .multilineTextAlignment(.leading)
                    .h2Style()
                    .foregroundStyle(.syncGrey)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if isLoadingImages {
                VStack {
                    ProgressView("Loading your photos...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundStyle(.syncGrey)
                }
                .frame(height: 200)
            } else {
                PhotoManagementGrid(
                    selectedImages: $selectedImages,
                    pickerItems: $pickerItems,
                    maxImageCount: maxImageCount,
                    onImageRemoved: { index in
                        Task {
                            await deleteImageAtIndex(index)
                        }
                    },
                    onImagesReordered: { newImages in
                        reorderImages(newImages)
                    },
                    onImageSelected: { index in
                        setupImageEditor(for: index)
                    }
                )
            }
            
            if !selectedImages.isEmpty {
                Text("Tap an image to adjust its position")
                    .bodyTextStyle()
                    .foregroundStyle(.syncGrey)
                    .padding(.top, 5)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .fitnessProfileConnector
                    }
                    Task {
                        await uploadAndSaveImages()
                    }
                }
                .disabled(selectedImages.count == 0)
                .onTapGesture {
                    if selectedImages.count == 0 {
                        showAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - Upload and Save Images
    private func uploadAndSaveImages() async {
        let uiSelectedImages = dbImages.map { $0.uiImage }
        let urls = await DBUserManager.shared.uploadPhoto(selectedImages: uiSelectedImages, uid: signUpModel.uid ?? "")
        
        // Ensure the URLs are correctly assigned to the corresponding DBImage objects
        var updatedImages = dbImages
        for (index, url) in urls.enumerated() {
            if index < updatedImages.count {
                updatedImages[index].url = url
            }
        }
        
        // Convert to Firestore format before saving
        let firestoreData = DBImage.arrayToFirestoreData(updatedImages)
        print("\(firestoreData)")
        
        await signUpModel.saveProgress(
            uid: signUpModel.uid ?? "",
            key: "images",
            value: firestoreData,
            onboardingStep: nil
        )
        
        // Update local state and model
        dbImages = updatedImages
        signUpModel.images = updatedImages
    }
    

    private func reorderImages(_ newImages: [UIImage]) {
        let newDBImages = newImages.compactMap { newImage in
            dbImages.first(where: { $0.uiImage === newImage })
        }
        if newDBImages.count == newImages.count {
            dbImages = newDBImages
        }
        selectedImages = newImages
        signUpModel.images = dbImages
    }
    
    private func setupImageEditor(for index: Int) {
        if index < dbImages.count {
            editingImageIndex = index
            currentOffset = CGSize(
                width: dbImages[index].offsetX.width,
                height: dbImages[index].offsetY.height
            )
            currentScale = dbImages[index].scale
        }
    }
    
    
    private var imageEditorContent: some View {
        ZStack {
            // Full screen black background
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 0) {
                // Image editor area
                GeometryReader { geo in
                    let screenWidth = geo.size.width
                    let screenHeight = geo.size.width * 1.2
                    
                    ZStack(alignment: .center) {
                        if let index = editingImageIndex, index < selectedImages.count {
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
    
    // MARK: - Helper Functions
    
    private func deleteImageAtIndex(_ index: Int) async {
        guard index < dbImages.count else { return }
        
        let imageToDelete = dbImages[index]
        
        // Only delete from storage if it has a URL (has been uploaded)
        if !imageToDelete.url.isEmpty {
            do {
                try await DBUserManager.shared.deletePhoto(url: imageToDelete.url)
                print("Successfully deleted image from storage")
            } catch {
                print("Error deleting image from storage: \(error)")
            }
        }
        
        // Remove from local arrays
        selectedImages.remove(at: index)
        dbImages.remove(at: index)
        
        // Update the sign up model
        signUpModel.images = dbImages
    }
    
    private func deleteAllUploadedImages() async {
        for dbImage in dbImages {
            if !dbImage.url.isEmpty {
                do {
                    try await DBUserManager.shared.deletePhoto(url: dbImage.url)
                    print("Successfully deleted image from storage: \(dbImage.url)")
                } catch {
                    print("Error deleting image from storage: \(error)")
                }
            }
        }
        
        // Clear all local data
        selectedImages.removeAll()
        dbImages.removeAll()
        signUpModel.images = []
    }
    
}
