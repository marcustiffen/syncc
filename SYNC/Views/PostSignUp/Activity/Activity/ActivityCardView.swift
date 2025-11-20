//import SwiftUI
//
//
//
//struct ActivityCardView: View {
//    let activity: Activity
//    
//    @EnvironmentObject var profileModel: ProfileModel
//    
//    @State var user: DBUser?
//    
//    @ObservedObject var viewModel: ActivityViewModel
//    @StateObject private var commentsManager: CommentsManager
//        
//    @State private var showComments: Bool = false
//    
//    @State private var showAlert: Bool = false
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//
//    init(activity: Activity, viewModel: ActivityViewModel) {
//        self.activity = activity
//        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
//        self.viewModel = viewModel
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack(alignment: .center) {
//                if let image = user?.images?.first {
//                    ImageLoaderView(urlString: image.url)
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 44, height: 44)
//                        .clipShape(Circle())
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.1))
//                        .frame(width: 44, height: 44)
//                }
//                
//                VStack(alignment: .leading) {
//                    if let name = user?.name {
//                        Text(name)
//                            .h2Style()
//                            .bold()
//                    }
//                    HStack {
//                        Text("Start time: \(formatDate(activity.startTime))")
//                            .bodyTextStyle()
//                        
//                        Spacer()
//                        Text(timeAgoString(from: activity.createdAt))
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            
//            Text(activity.name)
//                .h2Style()
//                .fontWeight(.semibold)
//            
//            if let description = activity.description {
//                Text(description)
//                    .h2Style()
//                    .foregroundColor(.secondary)
//            }
//            
//            if let location = activity.location {
//                Label(location.name, systemImage: "location.fill")
//                    .h2Style()
//                    .foregroundColor(.secondary)
//            }
//            
//            if let location = activity.location {
//                ActivityMapView(location: location)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 150)
//            }
//            
//            HStack {
//                if user?.uid != profileModel.user?.uid {
//                    participationSection
//                } else {
//                    seeWhosGoingSection
//                }
//                
//                Spacer()
//                Button {
////                    selectedActivity = activity
//                    showComments = true
//                    print("Show comments")
//                } label: {
//                    Image(systemName: "bubble")
//                        .foregroundColor(.black)
//                        .frame(width: 44, height: 44)
//                        .background(
//                            Circle().fill(.syncWhite)
//                        )
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(radius: 2)
//        .sheet(isPresented: $showComments) {
//            CommentsView(activity: activity)
//                .presentationDetents([.medium, .large])
//        }
//        .onAppear {
//            // get user
//            Task {
//                do {
//                    self.user = try await DBUserManager.shared.getUser(uid: activity.creatorId)
//                } catch {
//                    print("Can't get user")
//                }
//            }
//        }
//        .alert(Text(alertTitle), isPresented: $showAlert) {
//            Button("Cancel", role: .cancel) { }
//            Button("Confirm", role: .destructive) {
//                Task {
//                    if let currentUserId = user?.uid {
//                        try? await viewModel.cancelActivity(activity: activity, currentUserId: currentUserId)
//                        await viewModel.refreshActivity(activity: activity)
//                    }
//                }
//            }
//        } message: {
//            Text(alertMessage)
//        }
//
//    }
//    
//    
//    private var participationSection:  some View {
//        HStack {
//            Button {
//                Task {
//                    try await viewModel.joinActivity(activity: activity, currentUserId: user?.uid ?? "")
//                    await viewModel.refreshActivity(activity: activity)
//                    print("Going")
//                }
//            } label: {
//                Text(activity.participants.contains(where: { $0 == user?.uid ?? ""}) ? "Going" : "Join")
//                    .bodyTextStyle()
//                    .foregroundStyle(.syncBlack)
//                    .padding(5)
//                
//            }
//            .background(
//                (activity.participants.contains(user?.uid ?? ""))
//                ? AnyView(
//                    RoundedRectangle(cornerRadius: 100, style: .continuous)
//                        .foregroundStyle(.syncGreen)
//                        .shadow(radius: 2, x: 0, y: 0)
//                )
//                : AnyView(
//                    RoundedRectangle(cornerRadius: 100, style: .continuous)
//                        .fill(Color.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 100, style: .continuous)
//                                .stroke(Color.syncGreen, lineWidth: 2)
//                        )
//                        .shadow(radius: 2, x: 0, y: 0)
//                )
//            )
//
//            
//            if activity.participants.contains(where: { $0 == user?.uid ?? ""}) {
//                Button {
//                    alertTitle = "Wait!"
//                    alertMessage = "Are you sure you want to cancel your participation?"
//                    showAlert = true
//                } label: {
//                    Image(systemName: "xmark")
//                        .bodyTextStyle()
//                        .foregroundStyle(.syncWhite)
//                        .padding(5)
//                }
//                .background(
//                    RoundedRectangle(cornerRadius: 100, style: .continuous)
//                        .foregroundStyle(.syncBlack)
//                        .shadow(radius: 2, x: 0, y: 0)
//                )
//            }
//
//        }
//    }
//    
//    private var seeWhosGoingSection:  some View {
//        Button {
//            // show sheet for people who are attending
//        } label: {
//            let usersGoing = activity.participants
//            let firstThreeUsers = usersGoing.prefix(3)
//            
////            var activityUsers: [DBUser] = []
//            var images: [DBImage?] = []
//            
//            firstThreeUsers.forEach { userId in
//                Task {
//                    let fetchedUser = try await DBUserManager.shared.getUser(uid: userId)
//                    let fetchedImage = fetchedUser.images?.first
//                    images.append(fetchedImage)
//                }
//            }
//            
//            
//            ForEach(images.compactMap { $0 }, id: \.url) { image in
//                ImageLoaderView(urlString: image.url)
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                    .shadow(radius: 1)
//            }
//        }
//    }
//    
//    private func timeAgoString(from date: Date) -> String {
//        let seconds = Int(Date().timeIntervalSince(date))
//        
//        switch seconds {
//        case 0..<60:
//            return "\(seconds)s"
//        case 60..<3600:
//            return "\(seconds / 60)m"
//        case 3600..<86400:
//            return "\(seconds / 3600)h"
//        case 86400..<604800:
//            return "\(seconds / 86400)d"
//        default:
//            return "\(seconds / 604800)w"
//        }
//    }
//    
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}


import SwiftUI



struct ParticipantsPreviewView: View {
    let participantIds: [String]
    let maxVisible: Int = 3
    
    @State private var participantImages: [String: DBImage?] = [:]
    
    var body: some View {
        HStack(spacing: -8) {
            if participantIds.isEmpty {
                Text("No participants yet")
                    .bodyTextStyle()
                    .foregroundColor(.secondary)
            } else {
                let displayCount = min(participantIds.count, maxVisible)
                let shouldShowCounter = participantIds.count > maxVisible
                let imagesToShow = shouldShowCounter ? 2 : min(displayCount, 3)
                
                ForEach(0..<imagesToShow, id: \.self) { index in
                    if let image = participantImages[participantIds[index]]??.url {
                        ImageLoaderView(urlString: image)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 1)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 35, height: 35)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 1)
                    }
                }
                
                if shouldShowCounter {
                    ZStack {
                        Circle()
                            .fill(Color.syncGreen)
                            .frame(width: 35, height: 35)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 1)
                        
                        Text("+\(participantIds.count - 2)")
                            .bodyTextStyle()
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


struct ActivityCardView: View {
    let activity: Activity
    
    @EnvironmentObject var profileModel: ProfileModel
    
    @State var user: DBUser?
    
    @ObservedObject var viewModel: ActivityViewModel
    @StateObject private var commentsManager: CommentsManager
        
    @State private var showComments: Bool = false
    @State private var showParticipantsList: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    init(activity: Activity, viewModel: ActivityViewModel) {
        self.activity = activity
        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading/*, spacing: 8*/) {
            // Header with user info
            HStack(alignment: .center) {
                if let image = user?.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading) {
                    if let name = user?.name {
                        Text(name)
                            .h2Style()
                            .bold()
                    }
                    HStack {
                        Text("Start time: \(formatDate(activity.startTime))")
                            .bodyTextStyle()
                        
                        Spacer()
                        Text(timeAgoString(from: activity.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Activity info
            Text(activity.name)
                .bodyTextStyle()
                .fontWeight(.semibold)
            
            if let description = activity.description {
                Text(description)
                    .bodyTextStyle()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                Label(location.name, systemImage: "location.fill")
                    .bodyTextStyle()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                ActivityMapView(location: location)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
            }
            
            // Action buttons and participants
            HStack(spacing: 12) {
                Button {
                    showParticipantsList = true
                } label: {
                    HStack(spacing: 8) {
                        ParticipantsPreviewView(participantIds: activity.participants)
                        
                        if !activity.participants.isEmpty {
                            Text("\(activity.participants.count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                
                Spacer()
                
                Button {
                    showComments = true
                } label: {
                    Image(systemName: "bubble")
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle().fill(.syncWhite)
                        )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(activity: activity)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showParticipantsList) {
            ParticipantsListView(participantIds: activity.participants)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            Task {
                do {
                    self.user = try await DBUserManager.shared.getUser(uid: activity.creatorId)
                } catch {
                    print("Can't get user")
                }
            }
        }
        .alert(Text(alertTitle), isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                Task {
                    if let currentUserId = profileModel.user?.uid {
                        try? await viewModel.cancelActivity(activity: activity, currentUserId: currentUserId)
                        await viewModel.refreshActivity(activity: activity)
                    }
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var participationSection: some View {
        HStack(spacing: 8) {
            Button {
                Task {
                    guard let currentUserId = profileModel.user?.uid else { return }
                    try await viewModel.joinActivity(activity: activity, currentUserId: currentUserId)
                    await viewModel.refreshActivity(activity: activity)
                }
            } label: {
                Text(activity.participants.contains(profileModel.user?.uid ?? "") ? "Going" : "Join")
                    .bodyTextStyle()
                    .foregroundStyle(.syncBlack)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .background(
                activity.participants.contains(profileModel.user?.uid ?? "")
                ? AnyView(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .foregroundStyle(.syncGreen)
                        .shadow(radius: 2, x: 0, y: 0)
                )
                : AnyView(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                .stroke(Color.syncGreen, lineWidth: 2)
                        )
                        .shadow(radius: 2, x: 0, y: 0)
                )
            )
            
            if activity.participants.contains(profileModel.user?.uid ?? "") {
                Button {
                    alertTitle = "Wait!"
                    alertMessage = "Are you sure you want to cancel your participation?"
                    showAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .bodyTextStyle()
                        .foregroundStyle(.syncWhite)
                        .padding(8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .foregroundStyle(.syncBlack)
                        .shadow(radius: 2, x: 0, y: 0)
                )
            }
            
            // Show participant preview for non-creators too
            if !activity.participants.isEmpty {
                ParticipantsPreviewView(participantIds: activity.participants)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct ParticipantsListView: View {
    let participantIds: [String]
    @State private var participants: [DBUser] = []
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            titleView()
                .padding(.top, 10)
            
            Spacer()
            if !isLoading {
                ScrollView {
                    ForEach(participants, id: \.uid) { participant in
                        NavigationLink {
                            InspectUserView(likeAction: {}, dislikeAction: {}, user: participant)
                        } label: {
                            HStack {
                                if let image = participant.images?.first {
                                    ImageLoaderView(urlString: image.url)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                }
                                
                                Text(participant.name ?? "Unknown")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .padding(5)
                            .background(
                                Color.gray.opacity(0.1).clipShape(.rect(cornerRadius: 10))
                            )
                        }
                    }
                }
                .padding(.top, 10)
            } else {
                ProgressView("Loading Participants...")
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .task {
            isLoading = true
            await loadParticipants()
            isLoading = false
        }
    }
    
    private func loadParticipants() async {
        var loadedUsers: [DBUser] = []
        
        for userId in participantIds {
            do {
                let user = try await DBUserManager.shared.getUser(uid: userId)
                loadedUsers.append(user)
            } catch {
                print("Failed to load user \(userId): \(error)")
            }
        }
        
        self.participants = loadedUsers
    }
    
    private func titleView() -> some View {
        HStack {
            Text("Participants")
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
