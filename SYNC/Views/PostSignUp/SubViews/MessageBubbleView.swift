import SwiftUI


struct MessageBubbleView: View {
    let message: Message
    let isLastMessage: Bool
    
    @State private var showTime = false
    @EnvironmentObject private var profileModel: ProfileModel
    
    var body: some View {
        VStack(alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading) {
            HStack(alignment: .bottom) {
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
            .frame(maxWidth: 300, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
            
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
//                        .font(.caption)
                        .bodyTextStyle()
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    
                    if message.senderId != profileModel.user?.uid {
                        Spacer()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: message.senderId == profileModel.user?.uid ? .trailing : .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 3)
    }
}

