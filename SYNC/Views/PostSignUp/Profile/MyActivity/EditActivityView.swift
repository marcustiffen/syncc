struct EditActivityView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileModel: ProfileModel
    @ObservedObject var viewModel: MyActivityViewModel
    
    @Binding var activity: Activity
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            titleView()
            
            editFormView(activity: activity)
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
//        .task {
//            await loadActivity()
//        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func editFormView(activity: Activity) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            CustomOnBoardingTextField(
                placeholder: "Name",
                text: Binding(
                    get: { self.activity.name },
                    set: { self.activity.name = $0 }
                )
            )
            
            CustomOnBoardingTextField(
                placeholder: "Description",
                text: Binding(
                    get: { self.activity.description ?? "" },
                    set: { self.activity.description = $0.isEmpty ? nil : $0 }
                )
            )
            
            HStack {
                Text("Location:")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                
                Text("\(activity.location?.name ?? "No location")")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                    .bold()
                
                Spacer()
                
                NavigationLink {
                    EditLocationView(location: Binding(
                        get: { self.activity.location ?? .init() },
                        set: { self.activity.location = $0 }
                    ))
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
            
            DatePicker(
                "Start Time",
                selection: Binding(
                    get: { self.activity.startTime },
                    set: { self.activity.startTime = $0 }
                )
            )
            .font(.h2)
            
            HStack {
                Text("Maximum Participants:")
                    .foregroundStyle(.syncBlack)
                    .font(.h2)
                
                Spacer()
                
                Picker(
                    selection: Binding(
                        get: { self.activity.maxParticipants ?? 0 },
                        set: { self.activity.maxParticipants = $0 }
                    ),
                    label: Text("\(activity.maxParticipants ?? 0)")
                        .foregroundStyle(.syncBlack)
                        .font(.h2)
                        .bold()
                ) {
                    ForEach(0...50, id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }
                .tint(.syncBlack)
            }
            
            Spacer()
            
            Button {
                Task {
                    await saveActivity()
                }
            } label: {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .syncBlack))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                } else {
                    Text("Save Activity")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                }
            }
            .background(
                Rectangle()
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(isSaving ? Color.gray.opacity(0.5) : .syncGreen)
            )
            .disabled(isSaving)
            
            Spacer()
        }
    }
    
    private func saveActivity() async {        
        isSaving = true
        
        do {
            // Save to Firebase
            try await ActivityManager.shared.updateActivity(activity: activity)
            
            // Refresh the local list
            await viewModel.refresh(currentUserId: profileModel.user?.uid ?? "")
            
            dismiss()
        } catch {
            errorMessage = "Failed to update activity: \(error.localizedDescription)"
            showError = true
        }
        
        isSaving = false
    }
    
    private func titleView() -> some View {
        HStack {
            SyncBackButton {
                dismiss()
            }
            Text("Edit Activity")
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}