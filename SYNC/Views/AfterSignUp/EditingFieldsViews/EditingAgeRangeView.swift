import SwiftUI



struct EditingAgeRangeView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Binding var ageRange: CustomRange
    @Binding var isPresented: Bool
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        HStack {
            VStack {
                Text("Min Age")
                    .foregroundStyle(.syncBlack)
                    .font(.system(size: 16))
                Picker("Min Age", selection: Binding(
                    get: { ageRange.min },
                    set: { newValue in
                        ageRange.min = newValue
                    }
                )) {
                    ForEach(18..<100, id: \.self) { age in
                        Text("\(age)").tag(age)
                            .foregroundStyle(.syncBlack)
                    }
                }
                .scrollContentBackground(.hidden)
                .pickerStyle(WheelPickerStyle())
            }
            
            VStack {
                Text("Max Age")
                    .foregroundStyle(.syncBlack)
                    .font(.system(size: 16))
                Picker("Max Age", selection: Binding(
                    get: { ageRange.max },
                    set: { newValue in
                        ageRange.max = newValue
                    }
                )) {
                    ForEach(18..<100, id: \.self) { age in
                        Text("\(age)").tag(age)
                            .foregroundStyle(.syncBlack)
                    }
                }
                .scrollContentBackground(.hidden)
                .pickerStyle(WheelPickerStyle())
            }
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
