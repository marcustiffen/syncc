import SwiftUI

struct ActivityCardView: View {
    let activity: Activity
    
    @EnvironmentObject var profileModel: ProfileModel
    
    @State var user: DBUser?
    
    @ObservedObject var viewModel: ActivityViewModel
    @StateObject private var commentsManager: CommentsManager
        
    @State private var showComments: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""

    init(activity: Activity, viewModel: ActivityViewModel) {
        self.activity = activity
        self._commentsManager = StateObject(wrappedValue: CommentsManager(activityId: activity.id))
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            Text(activity.name)
                .h2Style()
                .fontWeight(.semibold)
            
            if let description = activity.description {
                Text(description)
                    .h2Style()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                Label(location.name, systemImage: "location.fill")
                    .h2Style()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                ActivityMapView(location: location)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
            }
            
            HStack {
                if user?.uid != profileModel.user?.uid {
                    participationSection
                } else {
                    
                }
                
                Spacer()
                Button {
//                    selectedActivity = activity
                    showComments = true
                    print("Show comments")
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
        .onAppear {
            // get user
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
                    if let currentUserId = user?.uid {
                        try? await viewModel.cancelActivity(activity: activity, currentUserId: currentUserId)
                        await viewModel.refreshActivity(activity: activity)
                    }
                }
            }
        } message: {
            Text(alertMessage)
        }

    }
    
    
    private var participationSection:  some View {
        HStack {
            Button {
                Task {
                    try await viewModel.joinActivity(activity: activity, currentUserId: user?.uid ?? "")
                    await viewModel.refreshActivity(activity: activity)
                    print("Going")
                }
            } label: {
                Text(activity.participants?.contains(where: { $0 == user?.uid ?? ""}) ?? false ? "Going!" : "Join Workout")
                    .bodyTextStyle()
                    .foregroundStyle(.syncBlack)
                    .padding(5)
                
            }
            .background(
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .foregroundStyle(.syncGreen)
                    .shadow(radius: 2, x: 0, y: 0)
            )
            
            if activity.participants?.contains(where: { $0 == user?.uid ?? ""}) ?? false {
                Button {
                    alertTitle = "Wait!"
                    alertMessage = "Are you sure you want to cancel your participation?"
                    showAlert = true
                } label: {
                    Image(systemName: "xmark")
                        .bodyTextStyle()
                        .foregroundStyle(.syncWhite)
                        .padding(5)
                }
                .background(
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .foregroundStyle(.syncBlack)
                        .shadow(radius: 2, x: 0, y: 0)
                )
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
