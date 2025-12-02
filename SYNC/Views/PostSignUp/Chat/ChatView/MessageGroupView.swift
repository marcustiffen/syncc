import SwiftUI


struct MessageGroupView: View {
    let group: MessageGroup
    let currentUserId: String
    
    @State private var user: DBUser?
    
    var body: some View {
        VStack(alignment: group.senderId == currentUserId ? .trailing : .leading, spacing: 2) {
            ForEach(Array(group.messages.enumerated()), id: \.element.id) { index, message in
                let isLastInGroup = index == group.messages.count - 1
                
                MessageBubbleView(
                    message: message,
                    isLastMessage: group.isLastOverall && isLastInGroup,
                    isLastInSequence: isLastInGroup,
                    user: user
                )
            }
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: group.senderId == currentUserId ? .trailing : .leading)
        .onAppear {
            if group.senderId != currentUserId {
                Task {
                    self.user = try? await DBUserManager.shared.getUser(uid: group.senderId)
                }
            }
        }
    }
}
