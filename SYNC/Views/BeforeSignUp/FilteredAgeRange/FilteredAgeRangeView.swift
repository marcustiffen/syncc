import SwiftUI

struct FilteredAgeRangeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .filterConnectorView
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filterConnectorView)

                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "lines.measurement.horizontal")
                Text("What age range do you want to see?")
            }
            .titleModifiers()
            
            HStack {
                VStack {
                    Text("Min Age")
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                    Picker("Min Age", selection: Binding(
                        get: { signUpModel.filteredAgeRange.min },
                        set: { newValue in
                            signUpModel.filteredAgeRange.min = newValue
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
                        get: { signUpModel.filteredAgeRange.max },
                        set: { newValue in
                            signUpModel.filteredAgeRange.max = newValue
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
            .onChange(of: signUpModel.filteredAgeRange.min) {
                if signUpModel.filteredAgeRange.min > signUpModel.filteredAgeRange.max {
                    showAlert = true
                }
            }
            .onChange(of: signUpModel.filteredAgeRange.max) {
                if signUpModel.filteredAgeRange.min > signUpModel.filteredAgeRange.max {
                    showAlert = true
                }
            }
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    FilteredSexView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredSex
                    }

                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredAgeRange", value: signUpModel.filteredAgeRange.toDictionary(), onboardingStep: .filteredSex)
                        
                    }
                }
                .disabled(signUpModel.filteredAgeRange.min > signUpModel.filteredAgeRange.max)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .alert("Error", isPresented: $showAlert) {
            Button("Okay") { }
        } message: {
            Text("Minimum age cannot be greater than maximum age!")
        }
    }
}
