//import SwiftUI
//
//
//struct MessageBubbleView: View {
//    let message: Message
//    let isLastMessage: Bool
//    
//    @State private var user: DBUser? = nil
//    
//    @State private var showTime = false
//    @EnvironmentObject private var profileModel: ProfileModel
//    
//    var body: some View {
//        VStack(alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading, spacing: 0) {
//            
//            HStack(alignment: .bottom) {
//                if message.senderId == profileModel.user?.uid {
//                    Spacer()
//                }
//                
//                Text(message.text)
//                    .bodyTextStyle()
//                    .padding(.horizontal, 15)
//                    .padding(.vertical, 10)
//                    .background(
//                        message.senderId == profileModel.user?.uid
//                        ? Color.syncGreen.opacity(0.9)
//                        : Color.syncGrey
//                    )
//                    .foregroundColor(
//                        message.senderId == profileModel.user?.uid
//                        ? Color.black
//                        : Color.white
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
//                    .onTapGesture {
//                        withAnimation(.easeInOut) {
//                            showTime.toggle()
//                        }
//                    }
//                
//                if message.senderId != profileModel.user?.uid {
//                    Spacer()
//                }
//            }
//            .padding(message.senderId == profileModel.user?.uid ? .trailing : .leading, 10)
//            .frame(maxWidth: 300, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
//            
//            if let image = user?.images?.first {
//                ImageLoaderView(urlString: image.url)
//                    .scaledToFit()
//                    .clipShape(Circle())
//                    .frame(width: 20, height: 20)
//            } else {
//                Circle()
//                    .foregroundStyle(.gray)
//                    .frame(width: 20, height: 20)
//            }
//            
//            // Status and Timestamp
//            if isLastMessage && message.senderId == profileModel.user?.uid {
//                HStack {
//                    Spacer()
//                    Text(message.seen ? "Seen" : "Delivered")
//                        .bodyTextStyle()
//                        .foregroundStyle(.gray)
//                        .padding(.top, 5)
//                }
//            } else if showTime {
//                HStack {
//                    if message.senderId == profileModel.user?.uid {
//                        Spacer()
//                    }
//                    
//                    Text(message.timestamp.formatted(.dateTime.hour().minute()))
//                        .bodyTextStyle()
//                        .foregroundColor(.gray)
//                        .padding(.top, 5)
//                    
//                    if message.senderId != profileModel.user?.uid {
//                        Spacer()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            Task {
//                self.user = try await DBUserManager.shared.getUser(uid: message.senderId)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
//        .padding(.horizontal, 16)
//        .padding(.vertical, 3)
//    }
//}
//
//
//
//
////struct MessageBubbleView_Previews: PreviewProvider {
////    static var previews: some View {
////        
////        // Mock ProfileModel so EnvironmentObject works
////        let profileModel = ProfileModel()
////        profileModel.user = DBUser(onboardingStep: .complete, deviceToken: "", uid: "", phoneNumber: "", email: "", name: "", dateOfBirth: Date(), sex: "", location: DBLocation.init(), bio: "", fitnessTypes: [], fitnessGoals: [], fitnessLevel: "", height: 0, weight: 0.0, images: [], filteredAgeRange: CustomRange(min: 0, max: 0), filteredSex: "", filteredMatchRadius: 0.0, filteredFitnessTypes: [], filteredFitnessGoals: [], filteredFitnessLevel: "", blockedSex: "", isBanned: false, dailyLikes: 0, lastLikeReset: Date())
////        
////        return VStack(spacing: 20) {
////            MessageBubbleView(
////                message: Message(id: "", text: "This is a dummy message", senderId: "", timestamp: Date(), seen: false),
////                isLastMessage: false
////            )
////            .environmentObject(profileModel)
////        }
////        .padding()
////        .previewLayout(.sizeThatFits)
////    }
////}



import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isLastMessage: Bool
    let isLastInSequence: Bool // NEW: Determines if this is the last message from this sender in a consecutive block
    
    @State private var user: DBUser? = nil
    @State private var showTime = false
    @EnvironmentObject private var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading, spacing: 0) {
            
            HStack(alignment: .bottom, spacing: 5) {
                if message.senderId == profileModel.user?.uid {
                    Spacer()
                }
                
                Text(message.text)
                    .bodyTextStyle()
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(
                        message.senderId == profileModel.user?.uid
                        ? Color.syncGreen.opacity(0.9)
                        : Color.syncGrey
                    )
                    .foregroundColor(
                        message.senderId == profileModel.user?.uid
                        ? Color.black
                        : Color.white
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            showTime.toggle()
                        }
                    }
                
                if message.senderId != profileModel.user?.uid {
                    Spacer()
                }
            }
            .padding(message.senderId == profileModel.user?.uid ? .trailing : .leading, message.senderId == profileModel.user?.uid ? 0 : 10)
            .frame(maxWidth: 300, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
            
            // Show avatar only if this is the last message in sequence AND not from current user
            if isLastInSequence && message.senderId != profileModel.user?.uid {
                // Avatar on the left for received messages
                if let image = user?.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 20, height: 20)
                } else {
                    Circle()
                        .foregroundStyle(.gray)
                        .frame(width: 20, height: 20)
                }
            } else if message.senderId != profileModel.user?.uid {
                // Spacer to maintain alignment when no avatar
                Spacer()
                    .frame(width: 20, height: 20)
            }
            
            // Status and Timestamp
            if isLastMessage && message.senderId == profileModel.user?.uid {
                HStack {
                    Spacer()
                    Text(message.seen ? "Seen" : "Delivered")
                        .bodyTextStyle()
                        .foregroundStyle(.gray)
                        .padding(.top, 5)
                }
            } else if showTime {
                HStack {
                    if message.senderId == profileModel.user?.uid {
                        Spacer()
                    }
                    
                    Text(message.timestamp.formatted(.dateTime.hour().minute()))
                        .bodyTextStyle()
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    
                    if message.senderId != profileModel.user?.uid {
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            Task {
                self.user = try await DBUserManager.shared.getUser(uid: message.senderId)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
}
