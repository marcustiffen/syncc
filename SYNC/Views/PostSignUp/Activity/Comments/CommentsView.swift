import SwiftUI



struct CommentsView: View {
    let activity: Activity
    
    @EnvironmentObject private var profileModel: ProfileModel
    @StateObject private var commentsManager: CommentsManager
    
    @State private var commentText = ""
    @State private var userCache: [String: DBUser] = [:]
    @FocusState private var isTextFieldFocused: Bool
    
    init(activity: Activity) {
        self.activity = activity
        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Comments List
            if commentsManager.isLoading && commentsManager.comments.isEmpty {
                Spacer()
                ProgressView("Loading comments...")
                    .h2Style()
                Spacer()
            } else if let errorMessage = commentsManager.errorMessage {
                Spacer()
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                Spacer()
            } else if commentsManager.comments.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .h1Style()
                        .foregroundColor(.secondary)
                    Text("No comments yet")
                        .h2Style()
                        .foregroundColor(.secondary)
                    Text("Be the first to comment!")
                        .h2Style()
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(commentsManager.comments) { comment in
                                CommentRowView(
                                    comment: comment,
                                    currentUserId: profileModel.user?.uid ?? "",
                                    onDelete: {
                                        Task {
                                            try? await commentsManager.deleteComment(
                                                commentId: comment.id,
                                                userId: profileModel.user?.uid ?? ""
                                            )
                                        }
                                    }
                                )
                                .environmentObject(commentsManager)
                                .id(comment.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: commentsManager.comments.count) {
                        if let lastComment = commentsManager.comments.last {
                            withAnimation {
                                proxy.scrollTo(lastComment.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Input Field
            inputView
        }
        .onAppear {
            commentsManager.startListening()
        }
        .onDisappear {
            commentsManager.stopListening()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Comments")
                .h2Style().bold()
            Spacer()
            Text("\(commentsManager.comments.count)")
                .bodyTextStyle()
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var inputView: some View {
        HStack(spacing: 12) {
            TextField("Add a comment...", text: $commentText, axis: .vertical)
                .h2Style()
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .focused($isTextFieldFocused)
                .lineLimit(1...5)
            
            Button {
                Task {
                    await sendComment()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .syncGreen)
            }
            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
    private func sendComment() async {
        let text = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, let userId = profileModel.user?.uid else { return }
        
        commentText = ""
        isTextFieldFocused = false
        
        do {
            try await commentsManager.postComment(text: text, userId: userId, activity: activity)
        } catch {
            print("Failed to post comment: \(error.localizedDescription)")
        }
    }
}





