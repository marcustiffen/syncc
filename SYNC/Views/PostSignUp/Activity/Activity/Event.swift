struct Event: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
}