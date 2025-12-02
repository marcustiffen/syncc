import SwiftUI

//struct MessageBubbleView: View {
//    let message: Message
//    let isLastMessage: Bool
//    let isLastInSequence: Bool // NEW: Determines if this is the last message from this sender in a consecutive block
//    
//    @State private var user: DBUser? = nil
//    @State private var showTime = false
//    @EnvironmentObject private var profileModel: ProfileModel
//    
//    var body: some View {
//        VStack(alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading, spacing: 0) {
//            
//            HStack(alignment: .bottom, spacing: 5) {
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
//            .padding(message.senderId == profileModel.user?.uid ? .trailing : .leading, message.senderId == profileModel.user?.uid ? 0 : 10)
//            .frame(maxWidth: 300, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
//            
//            // Show avatar only if this is the last message in sequence AND not from current user
//            if isLastInSequence && message.senderId != profileModel.user?.uid {
//                // Avatar on the left for received messages
//                if let image = user?.images?.first {
//                    ImageLoaderView(urlString: image.url)
//                        .scaledToFill()
//                        .clipShape(Circle())
//                        .frame(width: 20, height: 20)
//                } else {
//                    Circle()
//                        .foregroundStyle(.gray)
//                        .frame(width: 20, height: 20)
//                }
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


struct MessageBubbleView: View {
    let message: Message
    let isLastMessage: Bool
    let isLastInSequence: Bool
    let user: DBUser?
    
    @State private var showTime = false
    @EnvironmentObject private var profileModel: ProfileModel
    
    var isFromCurrentUser: Bool {
        message.senderId == profileModel.user?.uid
    }
    
    var body: some View {
        VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: 6) {
                if isFromCurrentUser {
                    Spacer(minLength: 60)
                }
                
                // Avatar (only for received messages, only on last in sequence)
                if !isFromCurrentUser && isLastInSequence {
                    if let image = user?.images?.first {
                        ImageLoaderView(urlString: image.url)
                            .scaledToFill()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .foregroundStyle(.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    }
                } else if !isFromCurrentUser {
                    // Spacer to maintain alignment
                    Color.clear.frame(width: 24, height: 24)
                }
                
                // Message Bubble
                Text(message.text)
                    .bodyTextStyle()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        isFromCurrentUser
                        ? Color.syncGreen.opacity(0.9)
                        : Color.syncGrey
                    )
                    .foregroundColor(
                        isFromCurrentUser
                        ? Color.black
                        : Color.white
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showTime.toggle()
                        }
                    }
                
                if !isFromCurrentUser {
                    Spacer(minLength: 60)
                }
            }
            
            // Timestamp
            if showTime {
                HStack {
                    if isFromCurrentUser { Spacer() }
                    Text(message.timestamp.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    if !isFromCurrentUser { Spacer() }
                }
                .padding(.horizontal, !isFromCurrentUser && isLastInSequence ? 30 : 0)
                .transition(.opacity)
            }
            
            // Status (only for last message from current user)
            if isLastMessage && isFromCurrentUser {
                HStack {
                    Spacer()
                    Text(message.seen ? "Seen" : "Delivered")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                .transition(.opacity)
            }
        }
    }
}
