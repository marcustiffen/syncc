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
    
    @StateObject var viewModel: CreateActivityViewModel
    
    init(profileModel: ProfileModel) {
        _viewModel = StateObject(wrappedValue: CreateActivityViewModel(
            initialLocation: profileModel.user?.location ?? .init()
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            titleView()
                .padding(.top, 50)
            
            Spacer()
            CustomOnBoardingTextField(placeholder: "Name", text: $viewModel.name)
            CustomOnBoardingTextField(placeholder: "Description", text: $viewModel.description)
            
            HStack {
                Text("Location:")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                
                Text("\(viewModel.location.name)")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                    .bold()
                
                Spacer()
                NavigationLink {
                    AddLocationView(viewModel: viewModel)
                        .environmentObject(profileModel)
                } label: {
                    Text("Edit")
                        .padding(.horizontal, 10)
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .padding(.vertical, 10)
                        .background(
                            Rectangle()
                                .clipShape(.rect(cornerRadius: 10))
                                .foregroundStyle(.syncGreen)
                        )
                }
            }
            
            DatePicker("Start Time", selection: $viewModel.startTime)
                .font(.h2)
            
            HStack {
                Text("Maximum Participants:")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                
                Spacer()
                
                Picker(selection: $viewModel.maxParticipants) {
                    ForEach(0...50) { index in
                        Text("\(index)")
                    }
                } label: {
                    Text("\(viewModel.maxParticipants)")
                        .foregroundStyle(.syncBlack)
                        .font(.h2)
                        .bold()
                }
                .tint(.syncBlack)
            }
            
            Spacer()
            
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
                Text("Create New Activity")
                    .padding(.horizontal, 10)
                    .foregroundStyle(.syncBlack)
                    .h2Style()
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(.syncGreen)
            )
            
            Spacer()

        }
        .padding(.horizontal, 10)
    }
    
    private func titleView() -> some View {
        HStack {
            Text("Create Activity")
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
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
    }
}
