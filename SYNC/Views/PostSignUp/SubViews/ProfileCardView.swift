import FirebaseStorage
import SDWebImageSwiftUI
import SwiftUI




struct ProfileCardView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    var user: DBUser?
    var isCurrentUser: Bool
    
    var usersFirstName: String {
        return user?.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    @State private var selectedImageIndex = 0
    @State private var sheetOffset: CGFloat = 0  // Will be calculated relative to screen
    @State private var lastDragValue: CGFloat = 0
    @State private var isInitialized = false
    
    var likeAction: () -> Void
    var dislikeAction: () -> Void
    
    init(user: DBUser?, isCurrentUser: Bool, likeAction: @escaping () -> Void, dislikeAction: @escaping () -> Void) {
        self.user = user
        self.isCurrentUser = isCurrentUser
        self.likeAction = likeAction
        self.dislikeAction = dislikeAction
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            let imageHeight = screenHeight * 0.65 // 65% of screen height
            let sheetMinOffset = screenHeight * 0.15 // 15% from top
            let sheetMaxOffset = screenHeight * 0.60 // 55% from top
            
            ZStack(alignment: .top) {
                // Image Carousel at the very top
                imageCarouselView(width: screenWidth, height: imageHeight)
                    .background(Color.white)
                    .zIndex(0)
                
                // NAME OVERLAY
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: imageHeight * 0.4) // Bottom 40% of image
                    
                    VStack(alignment: .center, spacing: screenHeight * 0.005) {
                        Text("\(user?.name ?? ""), \(user?.age ?? 0)")
                            .foregroundStyle(.white)
                            .h1Style()
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                        
                        Text("\(user?.location?.name ?? "")")
                            .foregroundStyle(.white)
                            .h2Style()
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                }
                .offset(y: imageHeight * 0.6)
                .zIndex(1)
                .allowsHitTesting(false)

                // CUSTOM DRAGGABLE SHEET
                VStack(alignment: .leading, spacing: 0) {
                    // Handle
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: screenWidth * 0.12, height: 8)
                        .padding(.top, screenHeight * 0.015)
                        .padding(.bottom, screenHeight * 0.02)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: screenHeight * 0.02) {
                            // Bio Section
                            bioSection()
                            
                            // Height and Weight Section
                            heightWeightSection(screenWidth: screenWidth)
                            
                            // Workout Preferences
                            workoutPreferencesSection(screenHeight: screenHeight)
                            
                            // Fitness Goals
                            fitnessGoalsSection(screenHeight: screenHeight)
                            
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, screenHeight * 0.02)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: sheetOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dragAmount = value.translation.height
                            sheetOffset = max(sheetMinOffset, min(sheetMaxOffset, lastDragValue + dragAmount))
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                let midPoint = (sheetMinOffset + sheetMaxOffset) / 2
                                if sheetOffset < midPoint {
                                    sheetOffset = sheetMinOffset
                                } else {
                                    sheetOffset = sheetMaxOffset
                                }
                            }
                            lastDragValue = sheetOffset
                        }
                )
                .zIndex(2)
                
                // Image indicators
                imageIndicators()
                    .offset(y: imageHeight * 0.02)
                    .zIndex(3)
                
                // Action buttons for non-current users
                if !isCurrentUser {
                    actionButtons(screenHeight: screenHeight, screenWidth: screenWidth)
                        .zIndex(4)
                }
            }
            .frame(maxHeight: screenHeight)
            .shadow(radius: 2)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if !isInitialized {
                    let maxOffset = screenHeight * 0.60
                    sheetOffset = maxOffset
                    lastDragValue = maxOffset
                    isInitialized = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func imageCarouselView(width: CGFloat, height: CGFloat) -> some View {
        TabView(selection: $selectedImageIndex) {
            if let images = user?.images, !images.isEmpty {
                ForEach(0..<images.count, id: \.self) { index in
                    ImageLoaderView(urlString: images[index].url)
                        .offset(x: images[index].offsetX.width, y: images[index].offsetY.height)
                        .scaleEffect(images[index].scale)
                        .clipped()
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("No images")
                            .foregroundColor(.gray)
                    )
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: width, height: height)
        .edgesIgnoringSafeArea(.top)
    }
    
    private func imageIndicators() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<(user?.images?.count ?? 0), id: \.self) { index in
                Capsule(style: .circular)
                    .fill(index == selectedImageIndex ? Color.syncWhite : Color.syncWhite.opacity(0.5))
                    .frame(width: index == selectedImageIndex ? 32 : 8, height: 8)
            }
        }
        .animation(.easeIn, value: selectedImageIndex)
        .padding(.horizontal, 16)
    }
    
    private func bioSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ABOUT")
                .foregroundStyle(.syncGrey)
                .tracking(2)
                .bodyTextStyle()
            
            if let userBio = user?.bio, userBio != "" {
                Text(userBio)
                    .foregroundStyle(.syncBlack)
                    .bodyTextStyle()
            } else {
                Text("No bio")
                    .foregroundStyle(.syncBlack)
                    .bodyTextStyle()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func heightWeightSection(screenWidth: CGFloat) -> some View {
        HStack(spacing: 16) {
            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("WEIGHT")
                    .foregroundStyle(.syncGrey)
                    .tracking(2)
                    .bodyTextStyle()
                
                if let userWeight = user?.weight, userWeight != 0.0 {
                    Text("\(String(format: "%.1f", userWeight)) kg")
                        .foregroundStyle(.white)
                        .bodyTextStyle()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.black.clipShape(Capsule()))
                }
            }
            
            Spacer()
            
            // Height
            VStack(alignment: .leading, spacing: 8) {
                Text("HEIGHT")
                    .foregroundStyle(.syncGrey)
                    .tracking(2)
                    .bodyTextStyle()
                
                if let userHeight = user?.height, userHeight != 0 {
                    Text("\(userHeight) cm")
                        .foregroundStyle(.white)
                        .bodyTextStyle()
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color.black.clipShape(Capsule()))
                }
            }
        }
    }
    
    private func workoutPreferencesSection(screenHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKOUT PREFERENCES")
                .foregroundStyle(.syncGrey)
                .tracking(2)
                .bodyTextStyle()
            
            FitnessTypesWrappedLayout(platforms: user?.fitnessTypes ?? [], isCurrentUser: isCurrentUser)
                .frame(minHeight: screenHeight * 0.08)
        }
    }
    
    private func fitnessGoalsSection(screenHeight: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FITNESS GOALS")
                .foregroundStyle(.syncGrey)
                .tracking(2)
                .bodyTextStyle()
            
            FitnessGoalsWrappedLayout(platforms: user?.fitnessGoals ?? [], isCurrentUser: isCurrentUser)
                .frame(minHeight: screenHeight * 0.08)
        }
    }
    
    private func actionButtons(screenHeight: CGFloat, screenWidth: CGFloat) -> some View {
        VStack {
            Spacer()
            HStack(spacing: screenWidth * 0.05) {
                Spacer()
                DislikeButton(user: user!) {
                    dislikeAction()
                }
                LikeButton(user: user!) {
                    likeAction()
                }
                Spacer()
            }
            .padding(.vertical, screenHeight * 0.02)
            .background(
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .foregroundStyle(.syncWhite)
                    .shadow(radius: 10, x: 0, y: 10)
                    .frame(width: screenWidth * 0.36, height: screenHeight * 0.09)
            )
            .padding(.bottom, screenHeight * 0.04)
        }
    }
}

// MARK: - Supporting Views

struct FitnessTypesWrappedLayout: View {
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    let platforms: [String]
    var isCurrentUser: Bool

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return Group {
            if platforms.isEmpty {
                Text("No Workout Preferences")
                    .bodyTextStyle()
            } else {
                ZStack(alignment: .topLeading) {
                    ForEach(platforms, id: \.self) { platform in
                        item(for: platform)
                            .padding(4)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if platform == platforms.last! {
                                    width = 0
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: { d in
                                let result = height
                                if platform == platforms.last! {
                                    height = 0
                                }
                                return result
                            })
                    }
                }
            }
        }
    }
    
    func item(for type: String) -> some View {
        HStack(spacing: 4) {
            Text(FitnessTypeHelper.emoji(for: type))
            Text(type)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.black)
        .bodyTextStyle()
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct FitnessGoalsWrappedLayout: View {
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    let platforms: [String]
    var isCurrentUser: Bool

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return Group {
            if platforms.isEmpty {
                Text("No Fitness Goals")
                    .bodyTextStyle()
            } else {
                ZStack(alignment: .topLeading) {
                    ForEach(platforms, id: \.self) { platform in
                        item(for: platform)
                            .padding(4)
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width) {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if platform == platforms.last! {
                                    width = 0
                                } else {
                                    width -= d.width
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: { d in
                                let result = height
                                if platform == platforms.last! {
                                    height = 0
                                }
                                return result
                            })
                    }
                }
            }
        }
    }
    
    func item(for goal: String) -> some View {
        HStack(spacing: 4) {
            Text(FitnessGoalHelper.emoji(for: goal))
            Text(goal)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .foregroundStyle(.black)
        .bodyTextStyle()
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .stroke(Color.black, lineWidth: 1)
        )
    }
}

struct ImageLoaderView: View {
    var urlString: String?
    
    var body: some View {
        if let url = urlString {
            Rectangle()
                .opacity(0.001)
                .overlay(
                    WebImage(url: URL(string: url))
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: .fill)
                        .allowsHitTesting(false)
                )
        } else {
            ProgressView()
        }
    }
}
