import FirebaseStorage
import SDWebImageSwiftUI
import SwiftUI



//my own version
struct ProfileCardView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    var user: DBUser?
    var isCurrentUser: Bool
    
    var usersFirstName: String {
        return user?.name?.split(separator: " ").first.map(String.init) ?? ""
    }
    
    @State private var selectedImageIndex = 0
    @State private var sheetOffset: CGFloat = 400  // Initial sheet position
    @State private var lastDragValue: CGFloat  // FIXED: Start at 400 instead of 0
    
    var likeAction: () -> Void
    var dislikeAction: () -> Void
    
    init(user: DBUser?, isCurrentUser: Bool, likeAction: @escaping () -> Void, dislikeAction: @escaping () -> Void) {
        self.user = user
        self.isCurrentUser = isCurrentUser
        self.likeAction = likeAction
        self.dislikeAction = dislikeAction
        _lastDragValue = State(initialValue: 400)  // FIXED: Ensure smooth first drag
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {  // FIXED: Align everything to the top
                // Image Carousel at the very top

                imageCarouselView(width: geometry.size.width)
                    .background(Color.white)
                    .zIndex(0)
                
                //NAME
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(maxHeight: .infinity)
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("\(user?.name ?? ""), \(user?.age ?? 0)")
                            .foregroundStyle(.white)
                            .h1Style()
                            .lineSpacing(30 * 1.5)
                        
                        Text("\(user?.location?.name ?? "")")
                            .foregroundStyle(.white)
                            .h2Style()
                            .lineSpacing(30 * 1.5)
                    }
                    .frame(maxWidth: .infinity)
                }
                .zIndex(1)
                .allowsHitTesting(false)

                // CUSTOM DRAGGABLE SHEET
                VStack(alignment: .leading, spacing: 10) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 50, height: 5)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    ScrollView(.vertical) {
                        // Bio
                        VStack(alignment: .leading) {
                            // info here
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
                        .padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Height and weight
                        HStack {
                            VStack(alignment: .leading) {
                                Text("WEIGHT")
                                    .foregroundStyle(.syncGrey)
                                    .tracking(2)
                                    .bodyTextStyle()
                                
                                if let userWeight = user?.weight, userWeight != 0.0 {
                                    Text("\(String(format: "%.1f", userWeight)) kg")
                                        .foregroundStyle(.white)
                                        .bodyTextStyle()
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Color.black.clipShape(Capsule())
                                        )
                                }
                            }
                            
                            Spacer(minLength: 100)
                            
                            VStack(alignment: .leading) {
                                Text("HEIGHT")
                                    .foregroundStyle(.syncGrey)
                                    .tracking(2)
                                    .bodyTextStyle()
                                
                                if let userHeight = user?.height, userHeight != 0 {
                                    Text("\(userHeight) cm")
                                        .foregroundStyle(.white)
                                        .bodyTextStyle()
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Color.black.clipShape(Capsule())
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        
                        // Workout Preferences
                        VStack(alignment: .leading) {
                            Text("WORKOUT PREFERENCES")
                                .foregroundStyle(.syncGrey)
                                .tracking(2)
                                .bodyTextStyle()
                            
                            FitnessTypesWrappedLayout(platforms: user?.fitnessTypes ?? [], isCurrentUser: isCurrentUser)
                                .frame(height: 100)
                        }
                        .padding(.vertical, 5)
                        
                        VStack(alignment: .leading) {
                            Text("FITNESS GOALS")
                                .foregroundStyle(.syncGrey)
                                .tracking(2)
                                .bodyTextStyle()
                            
                            FitnessGoalsWrappedLayout(platforms: user?.fitnessGoals ?? [], isCurrentUser: isCurrentUser)
                                .frame(height: 100)
                        }
                        .padding(.vertical, 5)
                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20)) // Add rounded corners
                .offset(y: sheetOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dragAmount = value.translation.height
                            sheetOffset = max(100, min(400, lastDragValue + dragAmount))  // Restrict movement
                        }
                        .onEnded { _ in
                            // Snap to top or bottom
                            withAnimation {
                                if sheetOffset < 250 {
                                    sheetOffset = 100 // Snap to top
                                } else {
                                    sheetOffset = 400 // Snap to bottom
                                }
                            }
                            lastDragValue = sheetOffset  // FIXED: Keep drag history smooth
                        }
                )
                .zIndex(2)
                
                interactionButtonsSection()
                    .padding(.top, 5)
                
                if isCurrentUser == false {
                    VStack {
                        Spacer()
                        ZStack {
                            HStack {
                                Spacer()
                                DislikeButton(user: user!) {
                                    dislikeAction()
                                }
                                .padding(.horizontal, 2)
                                LikeButton(user: user!) {
                                    likeAction()
                                }
                                .padding(.horizontal, 2)
                                Spacer()
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 100, style: .continuous)
                                    .foregroundStyle(.syncWhite)
                                    .shadow(radius: 10, x: 0, y: 10)
                                    .frame(width: 140, height: 70)
                                    .padding()
                            )
                        }
                        .padding(.bottom, 25)
                    }
                    .zIndex(3)
                }
                
            }
            .frame(maxHeight: geometry.size.height)
            .shadow(radius: 2)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    
    private func imageCarouselView(width: CGFloat) -> some View {
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
                    .frame(width: width, height: width * 1.2)
                    .overlay(
                        Text("No images")
                            .foregroundColor(.gray)
                    )
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: width, height: width * 1.2)
            .edgesIgnoringSafeArea(.top)
    }
    
    private func interactionButtonsSection() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<(user?.images?.count ?? 0), id: \.self) { index in
                Capsule(style: .circular)
                    .fill(index == selectedImageIndex ? Color.syncWhite : Color.syncWhite.opacity(0.5))
                    .frame(width: index == selectedImageIndex ? 32 : 8,
                           height: 8)
            }
        }
        .animation(.easeIn, value: selectedImageIndex)
        .padding(.horizontal, 5)
    }
}


struct FitnessTypesWrappedLayout: View {
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    let platforms: [FitnessType]
    var isCurrentUser: Bool

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.platforms, id: \.id) { platform in
                self.item(for: platform)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if platform == self.platforms.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if platform == self.platforms.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for type: FitnessType) -> some View {
        HStack(spacing: 2) {
            Text(type.emoji)
            Text(type.name)
        }
        .blur(radius: isCurrentUser == true || (subscriptionModel.isSubscriptionActive == true && isCurrentUser == false) ? 0 : 10)
        .foregroundStyle(.black)
        .lineLimit(1)
        .bodyTextStyle()
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .stroke(Color.black, lineWidth: 1)
        )
    }
}


struct FitnessGoalsWrappedLayout: View {
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    let platforms: [FitnessGoal]
    
    var isCurrentUser: Bool

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.platforms, id: \.id) { platform in
                self.item(for: platform)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if platform == self.platforms.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if platform == self.platforms.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(for type: FitnessGoal) -> some View {
        HStack(spacing: 2) {
            Text(type.emoji)
            Text(type.goal)
        }
        .blur(radius: isCurrentUser == true || (subscriptionModel.isSubscriptionActive == true && isCurrentUser == false) ? 0 : 10)
        .foregroundStyle(.black)
        .lineLimit(1)
        .bodyTextStyle()
        .padding(.vertical, 6)
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
