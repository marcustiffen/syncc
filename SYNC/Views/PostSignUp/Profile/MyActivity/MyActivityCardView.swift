import SwiftUI
import EventKit
import MapKit



struct MyActivityCardView: View {
    var activity: Activity
    
    @EnvironmentObject var profileModel: ProfileModel
    
    @State var user: DBUser?
    @State private var selectedUser: DBUser? = nil
    
    @ObservedObject var viewModel: MyActivityViewModel
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
    
    init(activity: Activity, viewModel: MyActivityViewModel) {
        self.activity = activity
        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with user info
            HStack(alignment: .center, spacing: 12) {
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
                
//                NavigationLink {
//                    EditActivityView(
//                        activityId: activity.id,
//                        viewModel: viewModel
//                    )
//                    .environmentObject(profileModel)
//                } label: {
//                    Image(systemName: "pencil")
//                        .foregroundStyle(.syncBlack)
//                }
                
                NavigationLink {
                    if let index = viewModel.activities.firstIndex(where: { $0.id == activity.id }) {
                        EditActivityView(
                            viewModel: viewModel, activity: $viewModel.activities[index]
                        )
                        .environmentObject(profileModel)
                    }
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(.syncBlack)
                }

            }
            
            // Activity content
            VStack(alignment: .leading, spacing: 12) {
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
                                removeFromCalendar()
                            } else {
                                requestCalendarAccess(activity: activity)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isInCalendar ? "calendar.badge.checkmark" : "calendar.badge.plus")
                                    .font(.system(size: 14, weight: .medium))
                                Text(isInCalendar ? "Added" : "Add")
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
            
            if let location = activity.location {
                ActivityMapView(location: location)
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            participationSection
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
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
