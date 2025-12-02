struct MessageGroup: Identifiable {
    let id: String
    let messages: [Message]
    let senderId: String
    let isLastOverall: Bool
}