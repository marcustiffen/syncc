import SwiftUI


class CreateActivityViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var location: DBLocation
    @Published var startTime: Date = Date()
    @Published var participants: [DBUser]? = nil
    @Published var maxParticipants: Int = 0
    
    init(initialLocation: DBLocation = .init()) {
        self.location = initialLocation
    }
    
    
    
    func createActivity(currentUserId: String) async throws {
        let newActivity = Activity(id: UUID().uuidString, creatorId: currentUserId, name: name, description: description, location: location, startTime: startTime, createdAt: Date(), participants: [currentUserId], status: "Upcoming", upvotes: nil, downvotes: nil, maxParticipants: maxParticipants)
        
        try await ActivityManager.shared.createActivity(userId: currentUserId, activity: newActivity)
    }
}



struct CreateActivityView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
//    @StateObject var viewModel = CreateActivityViewModel()
    @StateObject var viewModel: CreateActivityViewModel
    
    init(profileModel: ProfileModel) {
            _viewModel = StateObject(wrappedValue: CreateActivityViewModel(
                initialLocation: profileModel.user?.location ?? .init()
            ))
        }
    
    var body: some View {
        List {
            Section {
                TextField("Name", text: $viewModel.name)
                TextField("Description", text: $viewModel.description)
                                
                NavigationLink {
                    AddLocationView(viewModel: viewModel)
                        .environmentObject(profileModel)
                } label: {
                    Text("Location: \(viewModel.location.name)")
                }
                
                DatePicker("Start Time", selection: $viewModel.startTime)
                
                Picker(selection: $viewModel.maxParticipants) {
                    ForEach(0...50) { index in
                        Text("\(index)")
                    }
                } label: {
                    Text("Maximum Participants")
                }
            }
            
            Section {
                Button {
                    Task {
                        do {
                            try await viewModel.createActivity(currentUserId: profileModel.user?.uid ?? "")
                            dismiss()
                        } catch {
                            print("Error creating activivty: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    Text("Create Activity")
                }
            }
        }
    }
}



struct AddLocationView: View {
    
    @ObservedObject var viewModel: CreateActivityViewModel
    @EnvironmentObject var profileModel: ProfileModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    dismiss()
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                Text("Choose a location")
            }
            .titleModifiers()
            
            
            ZStack {
                MapView(location: $viewModel.location)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Image(systemName: "pin.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 20)
        }
        .navigationBarBackButtonHidden(true)
        .padding([.horizontal, .vertical], 20)
//        .onAppear {
//            viewModel.location = profileModel.user?.location ?? .init()
//        }
    }
}
