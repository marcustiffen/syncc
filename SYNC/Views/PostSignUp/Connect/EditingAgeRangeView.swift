import SwiftUI



struct EditingAgeRangeView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Binding var ageRange: CustomRange
    @Binding var isPresented: Bool
    
    let userManager: DBUserManager
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "lines.measurement.horizontal")
                Text("Edit your age range")
            }
            .titleModifiers()
            
            HStack {
                VStack {
                    Text("Min Age")
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                    Picker("Min Age", selection: Binding(
                        get: { ageRange.min },
                        set: { newMinValue in
                            ageRange.min = newMinValue
                        }
                    )) {
                        ForEach(18..<100, id: \.self) { age in
                            Text("\(age)").tag(age)
                                .h2Style()
                                .foregroundStyle(.syncBlack)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .pickerStyle(WheelPickerStyle())
                }
                
                VStack {
                    Text("Max Age")
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                    Picker("Max Age", selection: Binding(
                        get: { ageRange.max },
                        set: { newMaxalue in
                            ageRange.max = newMaxalue
//                            Task {
//                                try await userManager.updateUserField(
//                                    uid: profileModel.user?.uid ?? "",
//                                    field: "filteredAgeRange.max",
//                                    value: newValue
//                                )
//                            }
                        }
                    )) {
                        ForEach(18..<100, id: \.self) { age in
                            Text("\(age)").tag(age)
                                .h2Style()
                                .foregroundStyle(.syncBlack)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .pickerStyle(WheelPickerStyle())
                }
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.white
                .ignoresSafeArea()
        )
        .onChange(of: ageRange.min, {
            if ageRange.min > ageRange.max {
                showAlert = true
            }
        })
        .alert("Error", isPresented: $showAlert) {
            Button("Okay") { }
        } message: {
            Text("Minimum age cannot be greater than maximum age!")
        }
    }
}
