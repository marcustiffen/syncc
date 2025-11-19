import SwiftUI
import FirebaseFirestore

struct EditGroupView: View {
    @Environment(\.dismiss) var dismiss
    
    let chatRoom: ChatRoom
    @State private var groupName: String
    @State private var isSaving = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    init(chatRoom: ChatRoom) {
        self.chatRoom = chatRoom
        _groupName = State(initialValue: chatRoom.name)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            
            // Group Name Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Group Name")
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                
                TextField("Enter group name", text: $groupName)
                    .bodyTextStyle()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .autocapitalization(.words)
            }
            .padding()
            
            // Group Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Info")
                    .h2Style()
                    .foregroundStyle(.syncBlack)
                    .padding(.horizontal)
                
                HStack {
                    Text("Members")
                        .bodyTextStyle()
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(chatRoom.users.count)")
                        .bodyTextStyle()
                        .foregroundStyle(.syncBlack)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
                
                HStack {
                    Text("Created")
                        .bodyTextStyle()
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(chatRoom.createdAt.formatted(.dateTime.month().day().year()))
                        .bodyTextStyle()
                        .foregroundStyle(.syncBlack)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            
            // Save Button
            Button {
                saveGroupName()
            } label: {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Save Changes")
                        .h2Style()
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(groupName.isEmpty || groupName == chatRoom.name ? Color.gray : Color.syncGreen)
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(isSaving || groupName.isEmpty || groupName == chatRoom.name)
            
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Group name updated successfully")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Failed to update group name")
        }
    }
    
    private var headerSection: some View {
        HStack {
            SyncBackButton { dismiss() }
            Spacer()
            Text("Edit Group")
                .h1Style()
            Spacer()
            Spacer().frame(width: 44) // Balance the back button
        }
        .foregroundStyle(.syncBlack)
        .padding(.horizontal, 10)
        .padding(.bottom, 16)
    }
    
    private func saveGroupName() {
        guard !groupName.isEmpty, groupName != chatRoom.name else { return }
        
        isSaving = true
        
        let db = Firestore.firestore()
        let chatRoomRef = db.collection("chatRooms").document(chatRoom.id)
        
        chatRoomRef.updateData([
            "name": groupName
        ]) { error in
            isSaving = false
            
            if let error = error {
                print("Error updating group name: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showErrorAlert = true
            } else {
                print("Group name updated successfully")
                showSuccessAlert = true
            }
        }
    }
}