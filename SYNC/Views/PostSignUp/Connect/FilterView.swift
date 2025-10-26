import SwiftUI



struct FilterView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
        
    @State private var showEditingFitnessGoals = false
    @State private var showEditingFitnessTypes = false
    @State private var showEditingAgeRange = false
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var loadedFitnessGoals: [String] = StandardFitnessGoal.allCases.map(\.rawValue)
    @State private var loadedFitnessTypes: [String] = StandardFitnessType.allCases.map(\.rawValue)
    
    private let userManager = DBUserManager.shared
    
    @State private var filteredSexes = ["Male", "Female", "Both"]
    @State private var blockedSexes = ["None", "Male", "Female"]
    @State private var loadedFitnessLevels = ["Beginner", "Casual", "Active", "Intermediate", "Enthusiast", "Advanced", "Athlete", "Elite", "Any"]
    
    
    @State private var isEditMode: Bool = false
    @State private var isSaving: Bool = false
    
    @State private var showPayWallView: Bool = false
    
    @Binding var loadingViewFinishedLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SyncBackButton { dismiss() }
                Spacer()
            }
            .padding(.top, 20)
            
            
            // free
            VStack {
                HStack {
                    Text("Edit your filtered sex")
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                        .bold()
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: Binding(
                            get: { profileModel.user?.filteredSex ?? "Male" },
                            set: { newSex in
                                profileModel.user?.filteredSex = newSex
//                                Task {
//                                    try await userManager.updateUserField(uid: profileModel.user?.uid ?? "", field: "filteredSex", value: newSex)
//                                }
                            }
                        )) {
                            ForEach(filteredSexes, id: \.self) { sex in
                                Text(sex).tag(sex)
                            }
                        } label: {}
                    } label: {
                        Text("\(profileModel.user?.filteredSex ?? "")")
                            .foregroundStyle(.syncBlack)
                            .h2Style()
                    }
                }
                .padding(.vertical, 10)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("Maximum distance: ")
                            .h2Style()
                            .bold()
                        
                        Text("\(String(format: "%.0f", profileModel.user?.filteredMatchRadius ?? 0)) km")
                            .h2Style()
                    }
                    .foregroundStyle(.syncBlack)
                    
                    Slider(value: Binding(
                        get: { /*filteredMatchRadius ?? 0*/ profileModel.user?.filteredMatchRadius ?? 0}, // Default to 0 if nil
                        set: { radius in
                            profileModel.user?.filteredMatchRadius = radius
//                            Task {
//                                try await userManager.updateUserField(uid: profileModel.user?.uid ?? "", field: "filteredMatchRadius", value: radius)
//                            }
                        }  // Update the original value
                    ), in: 0...100, step: 1)
                    .tint(.syncBlack)
                }
                .padding(.vertical, 10)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                
                
                HStack {
                    Button(action: {
                        showEditingAgeRange = true // Show the weight picker
                    }) {
                        Text("Edit your age range")
                            .bold()
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                }
                .padding(.vertical, 20)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                .sheet(isPresented: $showEditingAgeRange) {
                    EditingAgeRangeView(ageRange: Binding(
                        get: { profileModel.user?.filteredAgeRange ?? CustomRange(min: 18, max: 100) },
                        set: { profileModel.user?.filteredAgeRange = $0 }
                    ), isPresented: $showEditingAgeRange, userManager: userManager)
                }
                
                
                // premium
                HStack {
                    Text("Edit your filtered fitness Level")
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                        .bold()
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: Binding(
                            get: { profileModel.user?.filteredFitnessLevel ?? "Any" },
                            set: { fitnessLevel in
                                // Only update fitness level if user is a subscriber
                                if subscriptionModel.isSubscriptionActive {
                                    profileModel.user?.filteredFitnessLevel = fitnessLevel
//                                    Task {
//                                        try await userManager.updateUserField(uid: profileModel.user?.uid ?? "", field: "filteredFitnessLevel", value: fitnessLevel)
//                                    }
                                } else {
                                    // Show paywall without changing the value
                                    showPayWallView = true
                                }
                            }
                        )) {
                            ForEach(loadedFitnessLevels, id: \.self) { level in
                                Text(level).tag(level)
                                
                            }
                        } label: {}
                    } label: {
                        Text("\(profileModel.user?.filteredFitnessLevel ?? "Any")")
                            .foregroundStyle(.syncBlack)
                            .h2Style()
                    }
                }
                .padding(.vertical, 10)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                
                // Fitness Types Section
                HStack {
                    Button(action: {
                        if subscriptionModel.isSubscriptionActive {
                            showEditingFitnessTypes = true // Show the weight picker
                        } else {
                            showPayWallView = true
                        }
                    }) {
                        Text("Edit your workout preferences")
                            .bold()
                            .h2Style()
                        Spacer()
                        Image(systemName: "chevron.down")
                            .h2Style()
                    }
                    
                    .foregroundStyle(.syncBlack)
                }
                .padding(.vertical, 20)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                .sheet(isPresented: $showEditingFitnessTypes) {
                    EditingFitnessTypesView(
                        titleText: "Edit your workout preferences",
                        fitnessTypes: Binding(
                            get: { profileModel.user?.filteredFitnessTypes ?? [] },
                            set: { profileModel.user?.filteredFitnessTypes = $0 }
                        ),
                        isPresented: $showEditingFitnessTypes, userManager: userManager)
                }
                
                
                // Similarly for Fitness Goals
                HStack {
                    Button(action: {
                        if subscriptionModel.isSubscriptionActive {
                            showEditingFitnessGoals = true
                        } else {
                            showPayWallView = true
                        }
                    }) {
                        Text("Edit which fitness goals you see")
                            .h2Style()
                            .bold()
                        Spacer()
                        Image(systemName: "chevron.down")
                            .h2Style()
                    }
                    .foregroundStyle(.syncBlack)
                }
                .padding(.vertical, 20)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
                .sheet(isPresented: $showEditingFitnessGoals) {
                    EditingFitnessGoalsView(
                        titleText: "Edit which fitness goals you see",
                        fitnessGoals: Binding(
                            get: { profileModel.user?.filteredFitnessGoals ?? [] },
                            set: { profileModel.user?.filteredFitnessGoals = $0 }
                        ),
                        isPresented: $showEditingFitnessGoals, userManager: userManager)
                }
                
                
                HStack(alignment: .bottom) {
                    Text("Edit your blocked Sex")
                        .h2Style()
                        .bold()
                    
                    Spacer()
                    
                    Menu {
                        Picker(selection: Binding(
                            get: { profileModel.user?.blockedSex ?? "None" },
                            set: { blockedSex in
                                // Only update fitness level if user is a subscriber
                                if subscriptionModel.isSubscriptionActive {
                                    profileModel.user?.blockedSex = blockedSex
//                                    Task {
//                                        try await userManager.updateUserField(uid: profileModel.user?.uid ?? "", field: "blockedSex", value: blockedSex)
//                                    }
                                } else {
                                    // Show paywall without changing the value
                                    showPayWallView = true
                                }
                            }
                        )) {
                            ForEach(blockedSexes, id: \.self) { sex in
                                Text("\(sex)").tag(sex)
                            }
                        } label: {}
                    } label: {
                        Text("\(profileModel.user?.blockedSex ?? "None")")
                            .h2Style()
                            .foregroundStyle(.syncBlack)
                    }
                }
                .padding(.vertical, 20)
                .background(
                    VStack {
                        Rectangle()
                            .fill(Color.syncBlack.opacity(0.1))
                            .frame(height: 2)
                        Spacer()
                    }
                )
            }
            .padding(.top, 20)
            
            
            Spacer()
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.white
                .ignoresSafeArea()
        )
        .onDisappear {
            saveChanges()
        }
    }
    
    private func saveChanges() {
        guard !isSaving else { return } // Prevent multiple saves
        isSaving = true
        
        Task {
            do {
                try await DBUserManager.shared.updateUser(profileModel.user!)
                
                await MainActor.run {
                    isEditMode = false
                    isSaving = false
                }
            } catch {
                print("Error saving filters: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
}


