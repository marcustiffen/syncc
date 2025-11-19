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
    @State private var sheetOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    @State private var isInitialized = false
    @State private var showEditSheet = false
    
    var showEditButton: Bool
    
    var likeAction: () -> Void
    var dislikeAction: () -> Void
    
    init(user: DBUser?, isCurrentUser: Bool, showEditButton: Bool, likeAction: @escaping () -> Void, dislikeAction: @escaping () -> Void) {
        self.user = user
        self.isCurrentUser = isCurrentUser
        self.showEditButton = showEditButton
        self.likeAction = likeAction
        self.dislikeAction = dislikeAction
    }

    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
//            let imageHeight = screenHeight * 0.55
            let imageHeight = screenHeight * 0.65
            let sheetMinOffset = screenHeight * 0.30
            let sheetMaxOffset = screenHeight * 0.60
            
            ZStack(alignment: .top) {
                imageCarouselView(width: screenWidth, height: imageHeight)
                    .background(Color.white)
                    .zIndex(0)
                
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: imageHeight * 0.4)
                    
                    VStack(alignment: .center, spacing: 4) {
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

                VStack(alignment: .leading, spacing: 0) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            bioSection()
                            heightWeightSection(screenWidth: screenWidth)
                            workoutPreferencesSection()
                            fitnessGoalsSection()
                            
                            if !isCurrentUser {
                                Spacer()
                                    .frame(height: 100)
                            } else {
                                Spacer()
                                    .frame(height: 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
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
                
                imageIndicators()
                    .offset(y: imageHeight * 0.02)
                    .zIndex(3)
                
                if showEditButton {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showEditSheet = true
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color.syncGreen))
                            }
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                        }
                        Spacer()
                    }
                    .zIndex(5)
                }
                
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
//                    let maxOffset = screenHeight * 0.50
                    let maxOffset = screenHeight * 0.60
                    sheetOffset = maxOffset
                    lastDragValue = maxOffset
                    isInitialized = true
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditView()
        }
    }
    
    
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
    
    private func workoutPreferencesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKOUT PREFERENCES")
                .foregroundStyle(.syncGrey)
                .tracking(2)
                .bodyTextStyle()
            
            FitnessTypesWrappedLayout(platforms: user?.fitnessTypes ?? [], isCurrentUser: isCurrentUser)
        }
    }
    
    private func fitnessGoalsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FITNESS GOALS")
                .foregroundStyle(.syncGrey)
                .tracking(2)
                .bodyTextStyle()
            
            FitnessGoalsWrappedLayout(platforms: user?.fitnessGoals ?? [], isCurrentUser: isCurrentUser)
        }
    }
    
    private func actionButtons(screenHeight: CGFloat, screenWidth: CGFloat) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Spacer()
                DislikeButton(user: user!) {
                    dislikeAction()
                }
                LikeButton(user: user!) {
                    likeAction()
                }
                Spacer()
            }
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .foregroundStyle(.syncWhite)
                    .shadow(radius: 10, x: 0, y: 10)
                    .frame(width: 160, height: 70)
            )
            .padding(.bottom, 30)
        }
    }
}


struct FitnessTypesWrappedLayout: View {
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    let platforms: [String]
    var isCurrentUser: Bool

    var body: some View {
        if platforms.isEmpty {
            Text("No Workout Preferences")
                .bodyTextStyle()
                .foregroundStyle(.syncGrey)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            FlowLayout(spacing: 8) {
                ForEach(platforms, id: \.self) { platform in
                    item(for: platform)
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
        if platforms.isEmpty {
            Text("No Fitness Goals")
                .bodyTextStyle()
                .foregroundStyle(.syncGrey)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            FlowLayout(spacing: 8) {
                ForEach(platforms, id: \.self) { platform in
                    item(for: platform)
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


struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
