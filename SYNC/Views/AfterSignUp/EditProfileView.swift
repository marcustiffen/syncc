import SwiftUI
import CoreLocation
import PhotosUI


struct EditProfileView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = 0
    let tabs = ["View", "Edit"]
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            
            // Custom Tab Selector
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(tabs[index])
//                                .font(.system(size: 16, weight: selectedTab == index ? .semibold : .regular))
                                .font(.h2)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundStyle(selectedTab == index ? .black : .gray)
                            
                            // Indicator Bar
                            Rectangle()
                                .fill(selectedTab == index ? Color.black : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 10)
            // Tab Content
            if selectedTab == 0 {
                ProfileCardView(user: profileModel.user, isCurrentUser: true, likeAction: {}, dislikeAction: {})
                    .padding(.top, 10)
            } else if selectedTab == 1 {
                EditView()
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton()
            Spacer()
            Text("profile")
                .h1Style()
            
            Spacer()
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
}


struct EditView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @State private var isEditing = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 10) {
                ScrollView(showsIndicators: false) {
                    PhotoSection()
                    LocationSection(profileModel: profileModel)
                    BioSection(profileModel: profileModel)
                    PhysicalInfoSection(profileModel: profileModel)
                    FitnessPreferencesSection(profileModel: profileModel)
                }
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onDisappear {
            Task {
                await saveProfile()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func saveProfile() async {
        guard let updatedUser = profileModel.user else { return }
        do {
            try await DBUserManager.shared.updateUser(updatedUser)
        } catch {
            print("Error updating user profile: \(error)")
        }
    }
}

// MARK: - Photo Section
struct PhotoSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Your Photos")
//                .bold()
                .h2Style()
            
            PhotoManagementView()
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 10)
    }
}

// MARK: - Location Section
struct LocationSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var showLocationEditView = false
    
    var body: some View {
        HStack {
            Button(action: { showLocationEditView = true }) {
                Text("Edit your Location")
                    
                Spacer()
                Image(systemName: "chevron.down")
            }
            .h2Style()
            .foregroundStyle(.syncBlack)
        }
        .padding(.vertical, 20)
        .background(SectionDivider())
        .sheet(isPresented: $showLocationEditView) {
            EditingLocationView(
                location: Binding(
                    get: { profileModel.user?.location ?? DBLocation(id: UUID(), name: "", location: CLLocationCoordinate2D(latitude: 0, longitude: 50)) },
                    set: { profileModel.user?.location = $0 }
                ),
                isPresented: $showLocationEditView
            )
        }
    }
}

// MARK: - Bio Section
struct BioSection: View {
    @ObservedObject var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Your Bio")
//                .bold()
                .h2Style()
            
//            TextField("Type here...", text: Binding(
//                get: { profileModel.user?.bio ?? "" },
//                set: { profileModel.user?.bio = $0 }
//            ), axis: .vertical)
            
            TextField("", text: Binding(
                get: { profileModel.user?.bio ?? "" },
                set: { profileModel.user?.bio = $0 }
            ), prompt: Text("Type here...").font(.h2).foregroundStyle(.syncGrey))
            .bodyTextStyle()
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
        .background(SectionDivider())
    }
}

// MARK: - Physical Info Section
struct PhysicalInfoSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var isEditingWeight = false
    let fitnessLevels = ["Beginner", "Casual", "Active", "Intermediate", "Enthusiast", "Advanced", "Athlete", "Elite", "Any"]
    
    var body: some View {
        VStack {
            // Height Picker
            HeightPicker(profileModel: profileModel)
            
            // Weight Editor
            WeightEditor(profileModel: profileModel, isEditingWeight: $isEditingWeight)
            
            // Fitness Level Picker
            FitnessLevelPicker(profileModel: profileModel, fitnessLevels: fitnessLevels)
        }
    }
}

// MARK: - Fitness Preferences Section
struct FitnessPreferencesSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var showEditingFitnessTypes = false
    @State private var showEditingFitnessGoals = false
    
    var body: some View {
        VStack {
            // Workout Preferences
            PreferenceButton(
                title: "Edit your workout preferences",
                isShowingSheet: $showEditingFitnessTypes
            ) {
                EditingFitnessTypesView(
                    titleText: "Edit your workout preferences",
                    fitnessTypes: Binding(
                        get: { profileModel.user?.fitnessTypes ?? [] },
                        set: { profileModel.user?.fitnessTypes = $0 }
                    ),
                    isPresented: $showEditingFitnessTypes
                )
            }
            
            // Fitness Goals
            PreferenceButton(
                title: "Edit your fitness goals",
                isShowingSheet: $showEditingFitnessGoals
            ) {
                EditingFitnessGoalsView(
                    titleText: "Edit your fitness goals",
                    fitnessGoals: Binding(
                        get: { profileModel.user?.fitnessGoals ?? [] },
                        set: { profileModel.user?.fitnessGoals = $0 }
                    ),
                    isPresented: $showEditingFitnessGoals
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct SectionDivider: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.syncBlack.opacity(0.1))
                .frame(height: 2)
            Spacer()
        }
    }
}


struct GradientOverlay: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .syncBlack.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 30)
            .allowsHitTesting(false)
    }
}


struct HeightPicker: View {
    @ObservedObject var profileModel: ProfileModel
    
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Edit Your Height")
                .h2Style()
            
            Spacer()
//            Picker("", selection: Binding(
//                get: { profileModel.user?.height ?? 0 },
//                set: { profileModel.user?.height = $0 }
//            )) {
//                ForEach(0...210, id: \.self) { height in
//                    Text("\(height) cm").tag(height)
//                }
//            }
//            .accentColor(.syncBlack)
            
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
//        .padding(.trailing, -14)
        .background(SectionDivider())
        
        
    }
}


struct WeightEditor: View {
    @ObservedObject var profileModel: ProfileModel
    @Binding var isEditingWeight: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Edit Your Weight")
//                .bold()
//                .h2Style()
            Spacer()
            Button(action: { isEditingWeight = true }) {
                Text("\(String(format: "%.1f", profileModel.user?.weight ?? 0.0)) kg")
                    .foregroundStyle(.syncBlack)
//                    .bodyTextStyle()
            }
        }
        .h2Style()
        .foregroundStyle(.syncBlack)
//        .padding(.vertical, 20)
        .padding(.vertical, 20)
        .background(SectionDivider())
        .sheet(isPresented: $isEditingWeight) {
            EditWeightView(
                weight: Binding(
                    get: { profileModel.user?.weight ?? 0.0 },
                    set: { profileModel.user?.weight = $0 }
                ),
                isPresented: $isEditingWeight
            )
        }
    }
}


struct FitnessLevelPicker: View {
    @ObservedObject var profileModel: ProfileModel
    let fitnessLevels: [String]
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Edit Your Fitness Level")
//                .bold()
                .h2Style()
            Spacer()
//            Picker("Fitness Level", selection: Binding(
//                get: { profileModel.user?.fitnessLevel ?? fitnessLevels.first ?? "Any" },
//                set: { profileModel.user?.fitnessLevel = $0 }
//            )) {
//                ForEach(fitnessLevels, id: \.self) { level in
//                    Text(level).bodyTextStyle().tag(level)
//                }
//            }
//            .accentColor(.syncBlack)
            
            Menu {
                Picker(selection: Binding(
                    get: { profileModel.user?.fitnessLevel ?? fitnessLevels.first ?? "Any" },
                    set: { profileModel.user?.fitnessLevel = $0 }
                )) {
                    ForEach(fitnessLevels, id: \.self) { level in
                        Text(level).bodyTextStyle().tag(level)
                    }
                } label: {}
            } label: {
                Text("\(profileModel.user?.fitnessLevel ?? "")")
                    .h2Style()
            }
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 20)
//        .padding(.trailing, -14)
        .background(SectionDivider())
    }
}


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


struct EditWeightView: View {
    @Binding var weight: Double
    @Binding var isPresented: Bool
    
    @State private var wholeNumber: Int
    @State private var decimalPart: Int
    
    init(weight: Binding<Double>, isPresented: Binding<Bool>) {
        self._weight = weight
        self._isPresented = isPresented
        // Extract the whole number and decimal part from the initial weight
        let whole = Int(weight.wrappedValue)
        let decimal = Int((weight.wrappedValue * 10).truncatingRemainder(dividingBy: 10))
        self._wholeNumber = State(initialValue: whole)
        self._decimalPart = State(initialValue: decimal)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "scalemass")
                Text("Edit weight")
            }
            .titleModifiers()
            
            HStack(spacing: 4) {
                Picker("Whole Number", selection: $wholeNumber) {
                    ForEach(0...150, id: \.self) { number in
                        Text("\(number)")
                            .bodyTextStyle()
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
                
                Text(".")
                    .bodyTextStyle()
                    .bold()
                
                Picker("Decimal Part", selection: $decimalPart) {
                    ForEach(0...9, id: \.self) { decimal in
                        Text("\(decimal)")
                            .bodyTextStyle()
                    }
                }
                .frame(maxWidth: .infinity)
                .pickerStyle(.wheel)
            }
            .padding()
            
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.syncWhite
                .ignoresSafeArea()
        )
        .onDisappear {
            weight = Double(wholeNumber) + Double(decimalPart) / 10.0
            isPresented = false
        }
    }
}


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



struct ImagePicker: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        let completion: (UIImage?) -> Void
        
        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else {
                completion(nil)
                return
            }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async {
                        self?.completion(image as? UIImage)
                    }
                }
            }
        }
    }
}

struct PhotoDropDelegateDBImage: DropDelegate {
    let item: DBImage
    let items: [DBImage]
    let completion: (_ draggedItem: DBImage, _ destinationIndex: Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = info.itemProviders(for: [.text]).first else { return false }

        draggedItem.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, _) in
            DispatchQueue.main.async {
                var urlString: String?

                if let str = data as? String {
                    urlString = str
                } else if let data = data as? Data {
                    urlString = String(data: data, encoding: .utf8)
                }

                guard let url = urlString,
                      let dragged = items.first(where: { $0.url == url }),
                      let destinationIndex = items.firstIndex(of: item)
                else {
                    print("⚠️ Failed to resolve dragged item from drop")
                    return
                }

                completion(dragged, destinationIndex)
            }
        }

        return true
    }

}
