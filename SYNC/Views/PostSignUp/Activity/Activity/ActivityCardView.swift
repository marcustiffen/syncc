import EventKit
import MapKit
import SwiftUI


struct Event: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
}



struct ActivityCardView: View {
    let activity: Activity
    
    @EnvironmentObject var profileModel: ProfileModel
    
    @State var user: DBUser?
    @State private var selectedUser: DBUser? = nil
    
    @ObservedObject var viewModel: ActivityViewModel
    @StateObject private var commentsManager: CommentsManager
        
    @State private var showComments: Bool = false
    @State private var showParticipantsList: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var showCalendarAlert = false
    @State private var isInCalendar = false
    @State private var showCalendarSuccess = false
    @State private var savedEventIdentifier: String?
    

    init(activity: Activity, viewModel: ActivityViewModel) {
        self.activity = activity
        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with user info
            HStack(alignment: .center, spacing: 12) {
//                if let image = user?.images?.first {
//                    ImageLoaderView(urlString: image.url)
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 48, height: 48)
//                        .clipShape(Circle())
//                        .onTapGesture {
//                            //
//                            selectedUser = user
//                        }
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.15))
//                        .frame(width: 48, height: 48)
//                }
                NavigationLink {
                    if let user = user {
                        InspectUserView(likeAction: {}, dislikeAction: {}, showHeader: true, showButtons: false, user: user)
                    }
                } label: {
                    if let image = user?.images?.first {
                        ImageLoaderView(urlString: image.url)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 48, height: 48)
                    }
                }

                
                VStack(alignment: .leading, spacing: 4) {
                    if let name = user?.name {
                        Text(name)
                            .font(.h2)
                            .bold()
                    }
                    Text(timeAgoString(from: activity.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Activity content
            VStack(alignment: .leading, spacing: 12) {
                // Activity name and description
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.name)
                        .bodyTextStyle()
                        .fontWeight(.bold)
                        .foregroundColor(.syncBlack)
                    
                    if let description = activity.description {
                        Text(description)
                            .bodyTextStyle()
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                
                // Time and location info
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.syncGreen)
                        Text(formatDate(activity.startTime))
                            .bodyTextStyle()
                            .foregroundColor(.syncBlack)
                        
                        Spacer()
                        
                        Button {
                            if isInCalendar {
                                // Remove from calendar
                                removeFromCalendar()
                            } else {
                                requestCalendarAccess(activity: activity)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isInCalendar ? "calendar.badge.checkmark" : "calendar.badge.plus")
                                    .font(.system(size: 14, weight: .medium))
                                Text(isInCalendar ? "Added" : "Add")
//                                    .font(.system(size: 13, weight: .medium))
                                    .bodyTextStyle()
                            }
                            .foregroundColor(isInCalendar ? .syncGreen : .syncBlack)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isInCalendar ? Color.syncGreen.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                        }
                    }
                    
                    if let location = activity.location {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.syncGreen)
                            Text(location.name)
                                .bodyTextStyle()
                                .foregroundColor(.syncBlack)
                                .lineLimit(1)
                        }
                    }
                }
            }
            
            // Map view
            if let location = activity.location {
                ActivityMapView(location: location)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Participation section
            participationSection
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
//        .sheet(item: $selectedUser) { user in
//            ProfileCardView(user: user, isCurrentUser: profileModel.user == user, showEditButton: false, likeAction: {}, dislikeAction: {})
//        }
        .sheet(isPresented: $showComments) {
            CommentsView(activity: activity)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showParticipantsList) {
            ParticipantsListView(participantIds: activity.participants)
                .environmentObject(profileModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showCalendarSuccess) {
            CalendarSuccessView(isPresented: $showCalendarSuccess)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
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
        .alert(alertTitle, isPresented: $showAlert) {
            if alertTitle == "Wait!" {
                Button("Cancel", role: .cancel) { }
                Button("Leave Activity") {
                    Task {
                        if let currentUserId = profileModel.user?.uid {
                            try? await viewModel.cancelActivity(activity: activity, currentUserId: currentUserId)
                            await viewModel.refreshActivity(activity: activity)
                        }
                    }
                }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func checkCalendarPermission() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    private func requestCalendarAccess(activity: Activity) {
        let eventStore = EKEventStore()
        
        eventStore.requestWriteOnlyAccessToEvents() { (granted, error) in
            DispatchQueue.main.async {
                if granted && error == nil {
                    let calendarEvent = EKEvent(eventStore: eventStore)
                    calendarEvent.title = activity.name
                    calendarEvent.startDate = activity.startTime
                    calendarEvent.endDate = calendarEvent.startDate.addingTimeInterval(3600)
                    calendarEvent.notes = activity.description
                    if let location = activity.location {
                        calendarEvent.structuredLocation = EKStructuredLocation(mapItem: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.location.latitude, longitude: location.location.longitude))))
                    }
                    
                    calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(calendarEvent, span: .thisEvent)
                        savedEventIdentifier = calendarEvent.eventIdentifier
                        isInCalendar = true
                        showCalendarSuccess = true
                    } catch {
                        alertTitle = "Error"
                        alertMessage = "Could not add activity to calendar: \(error.localizedDescription)"
                        showAlert = true
                    }
                } else {
                    alertTitle = "Calendar Access"
                    alertMessage = "Please enable calendar access in Settings to add activities."
                    showAlert = true
                }
            }
        }
    }
    
    private func removeFromCalendar() {
        guard let eventId = savedEventIdentifier else { return }
        
        let eventStore = EKEventStore()
        
        eventStore.requestWriteOnlyAccessToEvents() { (granted, error) in
            DispatchQueue.main.async {
                if granted && error == nil {
                    if let event = eventStore.event(withIdentifier: eventId) {
                        do {
                            try eventStore.remove(event, span: .thisEvent)
                            isInCalendar = false
                            savedEventIdentifier = nil
                            alertTitle = "Removed"
                            alertMessage = "Activity removed from your calendar."
                            showAlert = true
                        } catch {
                            alertTitle = "Error"
                            alertMessage = "Could not remove activity from calendar: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
    
    
    private var participationSection: some View {
        HStack(spacing: 12) {
            // Participation button
            if activity.creatorId != profileModel.user?.uid ?? "" {
                let isGoing = activity.participants.contains(profileModel.user?.uid ?? "")
                
                Button {
                    if isGoing {
                        alertTitle = "Wait!"
                        alertMessage = "Are you sure you want to leave this activity?"
                        showAlert = true
                    } else {
                        if activity.maxParticipants == activity.participants.count {
                            alertTitle = "Oops!"
                            alertMessage = "The maximum number of participants has been reached."
                            showAlert = true
                        } else {
                            Task {
                                guard let currentUserId = profileModel.user?.uid else { return }
                                try await viewModel.joinActivity(activity: activity, currentUserId: currentUserId)
                                await viewModel.refreshActivity(activity: activity)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: isGoing ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text(isGoing ? "Going" : "Join")
                            .font(.h2)
                            .bold()
                    }
                    .foregroundStyle(isGoing ? .syncBlack : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isGoing ? Color.syncGreen : Color.syncBlack)
                    )
                }
            }
            
            // Participants button
            Button {
                showParticipantsList = true
            } label: {
                HStack(spacing: 8) {
                    ParticipantsPreviewView(participantIds: activity.participants)
                    
                    if !activity.participants.isEmpty {
                        Text("\(activity.participants.count)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.syncBlack)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            Spacer()
            
            // Comments button
            Button {
                showComments = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.syncBlack)
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        switch seconds {
        case 0..<60:
            return "\(seconds)s ago"
        case 60..<3600:
            return "\(seconds / 60)m ago"
        case 3600..<86400:
            return "\(seconds / 3600)h ago"
        case 86400..<604800:
            return "\(seconds / 86400)d ago"
        default:
            return "\(seconds / 604800)w ago"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d 'at' h:mm a"
        return formatter.string(from: date)
    }
}


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
                    Text("No one yet")
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



struct ParticipantsListView: View {
    @EnvironmentObject var profileModel: ProfileModel
    
    let participantIds: [String]
    @State private var participants: [DBUser] = []
    
    @State private var selectedUser: DBUser? = nil
    @State private var showInspectUser: Bool = false
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            titleView()
                .padding(.top, 10)
            
            Spacer()
            if !isLoading {
                ScrollView {
                    ForEach(participants, id: \.uid) { participant in
                        Button {
                            selectedUser = participant
//                            showInspectUser = true
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
                                    .foregroundStyle(.syncBlack)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.syncGrey)
                                    .font(.system(size: 14))
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
        .sheet(item: $selectedUser) { user in
            ProfileCardView(user: user, isCurrentUser: profileModel.user == user, showButtons: false, showEditButton: false, likeAction: {}, dislikeAction: {})
        }
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


struct CalendarSuccessView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.syncGreen.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.syncGreen)
            }
            
            VStack(spacing: 8) {
                Text("Added to Calendar!")
                    .h1Style()
                    .foregroundStyle(.syncBlack)
                
                Text("You'll get a reminder when it's time")
                    .bodyTextStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button {
                isPresented = false
            } label: {
                Text("Done")
                    .h2Style()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.syncBlack)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
    }
}
