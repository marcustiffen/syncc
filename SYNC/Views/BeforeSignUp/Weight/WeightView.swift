import SwiftUI


struct WeightView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    // Separate bindings for whole and decimal parts
    @State private var wholeNumber: Int = 0 // Default whole number
    @State private var decimalPart: Int = 0  // Default decimal part
    
    var body: some View {
            VStack(spacing: 20) {
                // Header with Back and Skip buttons
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .height
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .height)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                            FiltersConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        signUpModel.weight = Double(wholeNumber) + Double(decimalPart) / 10.0
                        withAnimation {
                            signUpModel.onboardingStep = .filterConnectorView
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "weight", value: signUpModel.weight, onboardingStep: .filterConnectorView)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                
                // Prompt and explanation
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "scalemass")
                        Text("How much do you weigh?")
                    }
                    .titleModifiers()
                    
                    Text("NOTE: ")
                        .h2Style()
                        .bold()
                    Text("If you prefer not to say, just press the skip button up top!")
                        .multilineTextAlignment(.leading)
                        .h2Style()
                        .foregroundStyle(.syncGrey)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 4) {
                    // Whole number picker
                    Picker("Whole Number", selection: $wholeNumber) {
                        ForEach(0...150, id: \.self) { number in
                            Text("\(number)")
                                .h2Style()
                                .foregroundStyle(.syncBlack)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    
                    Text(".").h2Style().bold() // Decimal separator
                    
                    // Decimal part picker
                    Picker("Decimal Part", selection: $decimalPart) {
                        ForEach(0...9, id: \.self) { decimal in
                            Text("\(decimal)")
                                .h2Style()
                                .foregroundStyle(.syncBlack)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .pickerStyle(.wheel)
                    
                    Text("kg")
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                HStack {
                    Spacer()
//                    OnBoardingNavigationLink(text: "Next") {
//                        FiltersConnectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        signUpModel.weight = Double(wholeNumber) + Double(decimalPart) / 10.0
                        withAnimation {
                            signUpModel.onboardingStep = .filterConnectorView
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "weight", value: signUpModel.weight, onboardingStep: .filterConnectorView)

                        }
                    }
                }
            }
            
            
        
        .onDisappear {
            // Combine whole number and decimal part into a Double
            signUpModel.weight = Double(wholeNumber) + (Double(decimalPart) / 10.0)
        }
        
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
