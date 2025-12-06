struct ParticipantsPreviewView: View {
    let participantIds: [String]
    let maxVisible: Int = 3
    
    @State private var participantImages: [String: DBImage?] = [:]
    
    var body: some View {
        HStack(spacing: -10) {
            if participantIds.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "person.2")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("0")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            } else {
                let displayCount = min(participantIds.count, maxVisible)
                let shouldShowCounter = participantIds.count > maxVisible
                let imagesToShow = shouldShowCounter ? 2 : min(displayCount, 3)
                
                ForEach(0..<imagesToShow, id: \.self) { index in
                    if let image = participantImages[participantIds[index]]??.url {
                        ImageLoaderView(urlString: image)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                    }
                }
                
                if shouldShowCounter {
                    ZStack {
                        Circle()
                            .fill(Color.syncGreen)
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                        
                        Text("+\(participantIds.count - 2)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            await loadParticipantImages()
        }
        .onChange(of: participantIds) {
            Task {
                await loadParticipantImages()
            }
        }
    }
    
    private func loadParticipantImages() async {
        let idsToLoad = Array(participantIds.prefix(maxVisible))
        
        await withTaskGroup(of: (String, DBImage?).self) { group in
            for userId in idsToLoad {
                group.addTask {
                    do {
                        let user = try await DBUserManager.shared.getUser(uid: userId)
                        return (userId, user.images?.first)
                    } catch {
                        print("Failed to load user \(userId): \(error)")
                        return (userId, nil)
                    }
                }
            }
            
            for await (userId, image) in group {
                participantImages[userId] = image
            }
        }
    }
}