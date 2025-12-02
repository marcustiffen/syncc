struct ExpandableMessageInputView: View {
    let chatRoomId: String
    let messageReceiver: DBUser
    let messagesManager: MessagesManager
    
    @EnvironmentObject private var profileModel: ProfileModel
    @State private var messageText = ""
    @State private var textEditorHeight: CGFloat = 36
    @FocusState private var isFocused: Bool
    
    private let minHeight: CGFloat = 36
    private let maxHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Expandable Text Editor
                ZStack(alignment: .topLeading) {
                    // Placeholder
                    if messageText.isEmpty {
                        Text("Message")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .allowsHitTesting(false)
                    }
                    
                    // Text Editor with dynamic height
                    TextEditor(text: $messageText)
                        .frame(minHeight: minHeight, maxHeight: maxHeight)
                        .frame(height: textEditorHeight)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .focused($isFocused)
                        .onChange(of: messageText) { oldValue, newValue in
                            updateTextEditorHeight()
                        }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                
                // Send Button
                if !messageText.isEmpty {
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(Color.syncGreen)
                            .clipShape(Circle())
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: messageText.isEmpty)
        }
        .background(Color.white)
    }
    
    // MARK: - Dynamic Height Calculation
    private func updateTextEditorHeight() {
        let textView = UITextView()
        textView.text = messageText
        textView.font = UIFont.systemFont(ofSize: 16)
        
        let size = textView.sizeThatFits(CGSize(
            width: UIScreen.main.bounds.width - 100,
            height: .infinity
        ))
        
        let newHeight = max(minHeight, min(size.height + 8, maxHeight))
        
        withAnimation(.easeOut(duration: 0.1)) {
            textEditorHeight = newHeight
        }
    }
    
    // MARK: - Send Message
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let currentUser = profileModel.user else { return }
        
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        messagesManager.sendMessage(
            text: trimmedMessage,
            messageSender: currentUser,
            messageReceiver: messageReceiver
        )
        
        messageText = ""
        textEditorHeight = minHeight
        isFocused = true
    }
}