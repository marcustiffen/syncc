import SwiftUI

struct CommentRowView: View {
    let comment: Message
    let currentUserId: String
    let onDelete: () -> Void
    
    @EnvironmentObject var commentsManager: CommentsManager
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile Image
            if let user = commentsManager.users[comment.senderId],
               let image = user.images?.first {
                ImageLoaderView(urlString: image.url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 36, height: 36)
            }
            
            // Comment Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text(commentsManager.users[comment.senderId]?.name ?? "Loading...")
                        .h2Style()
                        .fontWeight(.semibold)
                    
                    Text(timeAgoString(from: comment.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.text)
                    .bodyTextStyle()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .contextMenu {
            if comment.senderId == currentUserId {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        switch seconds {
        case 0..<60:
            return "\(seconds)s"
        case 60..<3600:
            return "\(seconds / 60)m"
        case 3600..<86400:
            return "\(seconds / 3600)h"
        case 86400..<604800:
            return "\(seconds / 86400)d"
        default:
            return "\(seconds / 604800)w"
        }
    }
}
