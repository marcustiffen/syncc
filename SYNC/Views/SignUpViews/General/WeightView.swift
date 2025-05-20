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
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
//                        NavigationStack {
                            FiltersConnectorViews(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                        }
                    }
                    .onTapGesture {
                        signUpModel.weight = 0.0
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
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
    //                    NavigationStack {
                            FiltersConnectorViews(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
    //                    }
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
