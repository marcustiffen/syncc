import SwiftUI

struct NameView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var showAlert = false
    @State private var alertType: AlertType = .none
    
    
    enum AlertType {
        case none, name, firstName, lastName
    }
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                }
                .padding(.bottom, 40)
                

                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "person.text.rectangle")
                        Text("Enter your name")
                    }
                    .titleModifiers()
                    
                    Text("NOTE: ")
                        .bold()
                        .h2Style()
                    
                    Text("You can't change this information later!")
                        .bodyTextStyle()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.syncGrey)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                CustomOnBoardingTextField(placeholder: "First name", text: $signUpModel.firstName)
                CustomOnBoardingTextField(placeholder: "Last name", text: $signUpModel.lastName)
                
                Spacer()
                
                HStack {
                    Spacer()
                    OnBoardingNavigationLink(text: "Next") {
                        AgeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                    .disabled(
                        signUpModel.firstName == "" || signUpModel.lastName == ""
                    )
                    .onTapGesture {
                        if signUpModel.firstName == "" {
                            showAlert = true
                            alertType = .firstName
                        } else if signUpModel.lastName == "" {
                            showAlert = true
                            alertType = .lastName
                        } else if signUpModel.firstName == "" && signUpModel.lastName == "" {
                            showAlert = true
                            alertType = .name
                        }
                    }
                }
            }
        .onDisappear {
            if signUpModel.firstName == "" {
                showAlert = true
                alertType = .firstName
            } else if signUpModel.lastName == "" {
                showAlert = true
                alertType = .lastName
            } else if signUpModel.firstName == "" && signUpModel.lastName == "" {
                showAlert = true
                alertType = .name
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: {
                    switch alertType {
                    case .none:
                        return Text("Error")
                    case .name:
                        return Text("Both name fields cannot be empty")
                    case .firstName:
                        return Text("First name field cannot be empty")
                    case .lastName:
                        return Text("Last name field cannot be empty")
                    }
                }(),
                dismissButton: .default(Text("Okay"))
            )
        }

        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
