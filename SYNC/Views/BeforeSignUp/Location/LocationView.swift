import CoreLocation
import SwiftUI
import MapKit



struct LocationView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .sex
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .sex)
                            }

                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                    Text("Where do you live?")
                }
                .titleModifiers()
                
                
                ZStack {
                    MapView(location: $signUpModel.location)
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    Image(systemName: "pin.fill")
                        .font(.callout)
                        .foregroundStyle(.red)
                }
                .frame(maxHeight: .infinity)
                .padding(.vertical, 20)
                
                
                HStack {
                    Spacer()
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .bio
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "location", value: signUpModel.location.toFirestoreData(), onboardingStep: .bio)
                        }

                    }
                }
            }
            
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}

