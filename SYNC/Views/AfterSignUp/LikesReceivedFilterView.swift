import SwiftUI
import FirebaseFirestore
import Combine
import CoreLocation



//class LikesReceivedViewModel: ObservableObject {
//    @Published var likesReceived: [LikeReceived] = [] {
//        didSet {
//            // Trigger loadUsers whenever likesReceived changes
//            Task {
//                try? await self.loadUsers()
//            }
//        }
//    }
//    @Published var loadedUsers: [DBUser] = []
//    
//    // Filtering states
//    @Published var ageRange: ClosedRange<Int> = 18...100
//    @Published var selectedFitnessTypes: [FitnessType] = []
//    @Published var selectedFitnessLevel: String? = nil
//    @Published var selectedFitnessGoals: [FitnessGoal] = []
//    
//    
//    private let db = Firestore.firestore()
//    private var likesReceivedCancellables = Set<AnyCancellable>()
//    private var likesReceivedListener: ListenerRegistration? = nil
//    
//    private func likesReceivedCollection(uid: String) -> CollectionReference {
//        db.collection("users").document(uid).collection("likes_received")
//    }
//    
//    func addListenerForLikesReceived(uid: String) {
//        getLikesReceived(for: uid)
//            .receive(on: DispatchQueue.main) // Ensure updates are on the main thread
//            .sink { completion in
//                if case .failure(let error) = completion {
//                    print("Error in chat room listener: \(error)")
//                }
//            } receiveValue: { [weak self] likesReceived in
//                self?.likesReceived = likesReceived
//            }
//            .store(in: &likesReceivedCancellables)
//    }
//    
//    func getLikesReceived(for uid: String) -> AnyPublisher<[LikeReceived], any Error> {
//        let likesReceivedCollection = likesReceivedCollection(uid: uid)
//        let (publisher, listener) = likesReceivedCollection.addSnapShotListener(as: LikeReceived.self)
//        self.likesReceivedListener = listener
//        return publisher
//    }
//    
//    
//    func applyFilters() {
//        Task {
//            // Fetch the full list of users associated with likes received
//            let users: [DBUser] = try await withThrowingTaskGroup(of: DBUser.self) { group in
//                for like in likesReceived {
//                    group.addTask {
//                        try await DBUserManager.shared.getUser(uid: like.userId)
//                    }
//                }
//                
//                var results: [DBUser] = []
//                for try await user in group {
//                    results.append(user)
//                }
//                return results
//            }
//            
//            // Apply filters to the full list of users
//            let filteredUsers = users.filter { user in
//                // Filter by age range
//                if let age = user.age, !ageRange.contains(age) {
//                    return false
//                }
//                
//                // Filter by fitness types
//                if !selectedFitnessTypes.isEmpty,
//                   let userFitnessTypes = user.fitnessTypes,
//                    userFitnessTypes.contains(where: { type in
//                        !selectedFitnessTypes.contains(where: { $0.id == type.id })
//                    })
//                {
//                    return false
//                }
//                
//                // Filter by fitness level
//                if let fitnessLevel = selectedFitnessLevel,
//                   let userFitnessLevel = user.fitnessLevel,
//                   fitnessLevel != userFitnessLevel {
//                    return false
//                }
//                
//                // Filter by fitness goals
//                if !selectedFitnessGoals.isEmpty,
//                   let userFitnessGoals = user.fitnessGoals,
//                    userFitnessGoals.contains(where: { goal in
//                        !selectedFitnessGoals.contains(where: { $0.id == goal.id })
//                    })
//                {
//                    return false
//                }
//                
//                return true
//            }
//            
//            // Ensure state updates happen on the main thread
//            await MainActor.run {
//                self.loadedUsers = filteredUsers
//            }
//        }
//    }
//    
//    func loadUsers() async throws {
//        let users: [DBUser] = try await withThrowingTaskGroup(of: DBUser.self) { group in
//            for like in likesReceived {
//                group.addTask {
//                    try await DBUserManager.shared.getUser(uid: like.userId)
//                }
//            }
//            
//            var results: [DBUser] = []
//            for try await user in group {
//                results.append(user)
//            }
//            return results
//        }
//        
//        // Ensure state updates happen on the main thread
//        await MainActor.run {
//            self.loadedUsers = users
//        }
//    }
//}



//struct LikesReceivedFilterView: View {
//    @ObservedObject var likesReceivedViewModel: LikesReceivedViewModel
//    @Environment(\.dismiss) var dismiss
//    @State private var showAlert = false
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                filterContent
//            }
//            .padding()
//        }
//        .alert("Filters updated for your received likes", isPresented: $showAlert, actions: {
//            Button {
//                showAlert = false
//                dismiss()
//            } label: {
//                Text("Okay")
//            }
//        }, message: {
//            Text("")
//        })
//        .navigationTitle("Filters")
//    }
//    
//    private var filterContent: some View {
//        Group {
//            headerSection
//            ageRangeFilterCard
//            fitnessTypesFilterCard
//            fitnessLevelFilterCard
//            fitnessGoalsFilterCard
//            applyFiltersButton
//        }
//    }
//    
//    private var headerSection: some View {
//        Text("Customize Your Search")
//            .font(.title2)
//            .fontWeight(.bold)
//            .foregroundColor(.primary)
//            .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    
//    private var ageRangeFilterCard: some View {
//        FilterCardView(title: "Age Range") {
//            HStack {
//                Text("\(Int(likesReceivedViewModel.ageRange.lowerBound)) - \(Int(likesReceivedViewModel.ageRange.upperBound)) years")
//                    .fontWeight(.medium)
//                
//                Spacer()
//                
//                HStack {
//                    Text("From")
//                    Picker("Min Age", selection: lowerBoundBinding) {
//                        ForEach(18..<100, id: \.self) { age in
//                            Text("\(age)").tag(Double(age))
//                        }
//                    }
//                    .pickerStyle(.menu)
//                    .labelsHidden()
//                    
//                    Text("to")
//                    
//                    Picker("Max Age", selection: upperBoundBinding) {
//                        ForEach(18...100, id: \.self) { age in
//                            Text("\(age)").tag(Double(age))
//                        }
//                    }
//                    .pickerStyle(.menu)
//                    .labelsHidden()
//                }
//            }
//        }
//    }
//    
//    private var fitnessTypesFilterCard: some View {
//        FilterCardView(title: "Fitness Types") {
//            Menu {
//                ForEach(StandardFitnessType.allCases.map { FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji) }, id: \.id) { type in
//                    Button(likesReceivedViewModel.selectedFitnessTypes.contains(where: { $0.id == type.id }) ? "✔️ \(type.name)" : "\(type.name)") {
//                        toggleFitnessTypeSelection(type)
//                    }
//                }
//            } label: {
//                HStack {
//                    Text("Selected Types")
//                    Spacer()
//                    Text("(\(likesReceivedViewModel.selectedFitnessTypes.count))")
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//    }
//    
//    private var fitnessLevelFilterCard: some View {
//        FilterCardView(title: "Fitness Level") {
//            Picker("Fitness Level", selection: $likesReceivedViewModel.selectedFitnessLevel) {
//                Text("Any").tag(nil as String?)
//                Text("Beginner").tag("Beginner" as String?)
//                Text("Intermediate").tag("Intermediate" as String?)
//                Text("Advanced").tag("Advanced" as String?)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//        }
//    }
//    
//    private var fitnessGoalsFilterCard: some View {
//        FilterCardView(title: "Fitness Goals") {
//            Menu {
//                ForEach(StandardFitnessGoal.allCases.map { FitnessGoal(id: $0.id, goal: $0.rawValue, emoji: $0.emoji) }, id: \.id) { goal in
//                    Button(likesReceivedViewModel.selectedFitnessGoals.contains(where: { $0.id == goal.id }) ? "✔️ \(goal.goal)" : "\(goal.goal)") {
//                        toggleFitnessGoalSelection(goal)
//                    }
//                }
//            } label: {
//                HStack {
//                    Text("Selected Goals")
//                    Spacer()
//                    Text("(\(likesReceivedViewModel.selectedFitnessGoals.count))")
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//    }
//    
//    private var applyFiltersButton: some View {
//        Button(action: {
//            likesReceivedViewModel.applyFilters()
//            showAlert = true
//        }) {
//            Text("Apply Filters")
//                .fontWeight(.semibold)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//        }
//        .padding(.top)
//    }
//    
//    // Existing private helper methods remain the same...
//    
//    // MARK: - Bindings and Helpers
//    private var lowerBoundBinding: Binding<Double> {
//        Binding(
//            get: { Double(likesReceivedViewModel.ageRange.lowerBound) },
//            set: { likesReceivedViewModel.ageRange = Int($0)...likesReceivedViewModel.ageRange.upperBound }
//        )
//    }
//    
//    private var upperBoundBinding: Binding<Double> {
//        Binding(
//            get: { Double(likesReceivedViewModel.ageRange.upperBound) },
//            set: { newValue in
//                let boundedValue = max(18, min(Int(newValue), 100))
//                let lowerBound = min(likesReceivedViewModel.ageRange.lowerBound, boundedValue)
//                likesReceivedViewModel.ageRange = lowerBound...boundedValue
//            }
//        )
//    }
//    
//    private func toggleFitnessTypeSelection(_ type: FitnessType) {
//        if likesReceivedViewModel.selectedFitnessTypes.contains(where: { $0.id == type.id }) {
//            likesReceivedViewModel.selectedFitnessTypes.removeAll(where: { $0.id == type.id })
//        } else {
//            likesReceivedViewModel.selectedFitnessTypes.append(type)
//        }
//    }
//    
//    private func toggleFitnessGoalSelection(_ goal: FitnessGoal) {
//        if likesReceivedViewModel.selectedFitnessGoals.contains(where: { $0.id == goal.id }) {
//            likesReceivedViewModel.selectedFitnessGoals.removeAll(where: { $0.id == goal.id })
//        } else {
//            likesReceivedViewModel.selectedFitnessGoals.append(goal)
//        }
//    }
//}

// Helper view for consistent card-like styling
struct FilterCardView<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
