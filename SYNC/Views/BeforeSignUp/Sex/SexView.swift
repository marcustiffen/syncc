import SwiftUI

struct SexView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var sexes = ["Male", "Female"]
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .age
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .age)
                        }

                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "person")
                    Text("Choose your sex")
                }
                .titleModifiers()
                
                Text("NOTE: ")
                    .bold()
                    .h2Style()
                Text("You cannot change your sex later on!")
                    .multilineTextAlignment(.leading)
                    .bodyTextStyle()
                    .foregroundStyle(.syncGrey)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            CustomSegmentPicker(options: sexes, selected: $signUpModel.sex)
            
            Spacer()
            
            HStack {
                Spacer()
                
//                OnBoardingNavigationLink(text: "Next") {
//                    LocationView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .location
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "sex", value: signUpModel.sex, onboardingStep: .location)
                    }

                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}



struct CustomSegmentPicker: View {
    let options: [String]
    @Binding var selected: String
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                SegmentButton(
                    title: option,
                    isSelected: selected == option,
                    action: { selected = option }
                )
            }
        }
        .animation(.easeIn, value: selected)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.syncBlack, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .h2Style()
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.syncGreen : Color.clear)
                .foregroundColor(.syncBlack)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}
