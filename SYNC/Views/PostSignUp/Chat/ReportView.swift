import SwiftUI



struct ReportView: View {
    @EnvironmentObject private var profileModel: ProfileModel
    @Environment(\.dismiss) var dismiss
    private let reportManager = ReportManager()
    
    @StateObject private var matchMakingManager = MatchMakingManager()
    
    let reportedUser: DBUser
    
    @State private var selectedReason: String = ""
    @State private var customReason: String = ""
    @State private var isOtherSelected: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var showConfirmationAlert = false
    
    private let reportReasons = [
        "Inappropriate messages",
        "Harassment or bullying",
        "Spam or scam",
        "Fake profile",
        "Hate speech",
        "Sexual content",
        "Threats or violence",
        "Other"
    ]
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Text("Report User")
                    .h1Style()
                    .bold()
                Spacer()
            }
            .padding()
            
            Text("Why are you reporting \(reportedUser.name ?? "this user")?")
                .h2Style()
                .font(.headline)
                .padding(.top, 10)
            
            ScrollView(.vertical) {
                // List of report reasons
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(reportReasons, id: \.self) { reason in
                        Button(action: {
                            selectedReason = reason
                            isOtherSelected = (reason == "Other")
                            // Clear custom reason if switching away from "Other"
                            if reason != "Other" {
                                customReason = ""
                            }
                        }) {
                            HStack {
                                Text(reason)
                                    .foregroundColor(.black)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .bodyTextStyle()
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
                
                // Custom input field for "Other"
                if isOtherSelected {
                    CustomOnBoardingTextField(placeholder: "Enter your reason", text: $customReason)
                        .padding()
                }
                
                Spacer()
                
                // Submit button
                Button(action: submitReport) {
                    Text(isSubmitting ? "Submitting..." : "Submit Report")
                        .h2Style()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedReason.isEmpty || (isOtherSelected && customReason.isEmpty) ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedReason.isEmpty || (isOtherSelected && customReason.isEmpty))
                .padding()
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Report Submitted"),
                        message: Text("Thank you for your report. Our team will review this case."),
                        dismissButton: .default(Text("OK")) {
                            let currentUserId = profileModel.user?.uid ?? ""
                            dismiss()
                            matchMakingManager.unmatchUser(currentUserId: currentUserId, unmatchedUserId: reportedUser.uid) { result in
                                switch result {
                                case .success:
                                    dismiss()
                                    print("Unmatched user")
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
    
    // Report submission function
    private func submitReport() {
        guard !selectedReason.isEmpty else { return }
        
        isSubmitting = true
        let reasonToSubmit = isOtherSelected ? customReason : selectedReason
        
        reportManager.reportUser(
            reportedUserId: reportedUser.uid,
            reportedByUserId: profileModel.user?.uid ?? "",
            reason: reasonToSubmit
        ) { success in
            DispatchQueue.main.async {
                isSubmitting = false
                if success {
                    showConfirmationAlert = true
                } else {
                    print("Failed to submit report.")
                }
            }
        }
    }
}
