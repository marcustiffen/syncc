import SwiftUI


struct FilterView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    @EnvironmentObject var completeUsersModel: CompleteUsersModel
    
    @Binding var isLoading: Bool
    
    @State private var showEditingFitnessGoals = false
    @State private var showEditingFitnessTypes = false
    @State private var showEditingAgeRange = false
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var loadedFitnessGoals: [FitnessGoal] = StandardFitnessGoal.allCases.map {
        FitnessGoal(id: $0.id, goal: $0.rawValue, emoji: $0.emoji)
    }
    
    @State private var loadedFitnessTypes: [FitnessType] = StandardFitnessType.allCases.map {
        FitnessType(id: $0.id, name: $0.rawValue, emoji: $0.emoji)
    }
    
    @State private var sexes = ["Male", "Female", "Both"]
    @State private var loadedFitnessLevels = ["Beginner", "Casual", "Active", "Intermediate", "Enthusiast", "Advanced", "Athlete", "Elite", "Any"]
    
    @Binding var filteredAgeRange: CustomRange?
    @Binding var filteredSex: String?
    @Binding var filteredMatchRadius: Double?
    @Binding var filteredFitnessTypes: [FitnessType]?
    @Binding var filteredFitnessGoals: [FitnessGoal]?
    @Binding var filteredFitnessLevel: String
    
    @State private var isEditMode: Bool = false
    @State private var isSaving: Bool = false
    
    @State private var showPayWallView: Bool = false
    
    @Binding var loadingViewFinishedLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SyncBackButton()
                Spacer()
            }
            .padding(.top, 20)
            
            Spacer()
            
            
            // free
            HStack {
                Text("Edit your filtered sex")
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                    .bold()
                
                Spacer()
//                Picker("", selection: Binding(
//                    get: { profileModel.user?.filteredSex ?? "Male" },
//                    set: { newSex in
//                        profileModel.user?.filteredSex = newSex
//                    }
//                )) {
//                    ForEach(sexes, id: \.self) { sex in
//                        Text(sex).tag(sex)
//                    }
//                }
//                .accentColor(.syncBlack)
                
                Menu {
                    Picker(selection: Binding(
                        get: { profileModel.user?.filteredSex ?? "Male" },
                        set: { newSex in
                            profileModel.user?.filteredSex = newSex
                        }
                    )) {
                        ForEach(sexes, id: \.self) { sex in
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
                    
                    Text("\(String(format: "%.0f", filteredMatchRadius ?? 0)) km")
                        .h2Style()
                }
                .foregroundStyle(.syncBlack)
                
                Slider(value: Binding(
                    get: { filteredMatchRadius ?? 0 }, // Default to 0 if nil
                    set: { filteredMatchRadius = $0 }  // Update the original value
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
                ), isPresented: $showEditingAgeRange)
            }

            
            // premium
            HStack {
                Text("Edit your filtered fitness Level")
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                    .bold()
                
                Spacer()
                
//                Picker("Fitness Level", selection: Binding(
//                    get: { profileModel.user?.filteredFitnessLevel ?? loadedFitnessLevels.first ?? "Any" },
//                    set: { fitnessLevel in
//                        // Only update fitness level if user is a subscriber
//                        if subscriptionModel.isSubscriptionActive {
//                            profileModel.user?.filteredFitnessLevel = fitnessLevel
//                        } else {
//                            // Show paywall without changing the value
//                            showPayWallView = true
//                        }
//                    }
//                )) {
//                    ForEach(loadedFitnessLevels, id: \.self) { level in
//                        Text(level).tag(level)
//                    }
//                }
//                .accentColor(.syncBlack)
                Menu {
                    Picker(selection: Binding(
                        get: { profileModel.user?.filteredFitnessLevel ?? loadedFitnessLevels.first ?? "Any" },
                        set: { fitnessLevel in
                            // Only update fitness level if user is a subscriber
                            if subscriptionModel.isSubscriptionActive {
                                profileModel.user?.filteredFitnessLevel = fitnessLevel
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
                    isPresented: $showEditingFitnessTypes)
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
                    titleText: "Edit which fitness goals you see", fitnessGoals: Binding(
                        get: { profileModel.user?.filteredFitnessGoals ?? [] },
                        set: { profileModel.user?.filteredFitnessGoals = $0 }
                    ), isPresented: $showEditingFitnessGoals)
            }
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
        isSaving = true
        Task {
            do {
                try await DBUserManager.shared.updateUser(profileModel.user!)
                isEditMode = false
                isSaving = false
            } catch {
                print("Error saving filters: \(error)")
                isSaving = false
            }
        }
    }
}
