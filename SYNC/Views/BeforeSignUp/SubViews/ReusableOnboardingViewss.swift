import Foundation
import SwiftUI


struct OnBoardingButton: View {
    let text: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }) {
            Text(text)
                .padding(.horizontal, 10)
                .foregroundStyle(.syncBlack)
                .h2Style()
                .padding(.vertical, 10)
                .frame(minWidth: 150)
                .cornerRadius(10)
                .shadow(color: isPressed ? .syncGreen.opacity(0.7) : .clear, radius: 10)
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .animation(.easeOut(duration: 0.2), value: isPressed)
        }
        .background(
            Rectangle()
                .clipShape(.rect(cornerRadius: 10))
                .foregroundStyle(.syncGreen)
        )
    }
}

struct OnBoardingNavigationLink<Destination: View>: View {
    let text: String
    let destination: () -> Destination
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination()) {
            Text(text)
                .padding(.horizontal, 10)
                .foregroundStyle(.syncBlack)
                .h2Style()
                .padding(.vertical, 10)
                .frame(minWidth: 150)
                .cornerRadius(10)
                .shadow(color: isPressed ? .syncGreen.opacity(0.7) : .clear, radius: 10)
                .scaleEffect(isPressed ? 1.1 : 1.0)
                .animation(.easeOut(duration: 0.2), value: isPressed)
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 0.01).onChanged { _ in
            isPressed = true
        }.onEnded { _ in
            isPressed = false
        })
        .background(
            Rectangle()
                .clipShape(.rect(cornerRadius: 10))
                .foregroundStyle(.syncGreen)
        )
    }
}

struct OnBoardingNavigationLinkSkip: View {
    let action: () -> Void
    
    var body: some View {
//        NavigationLink(destination: destination()) {
//            Text("Skip")
//                .h2Style()
//                .foregroundStyle(.syncBlack)
//        }
        Button {
            action()
        } label: {
            Text("Skip")
                .h2Style()
                .foregroundStyle(.syncBlack)
        }
    }
}


//struct CustomOnBoardingTextEditor: View {
//    @Binding var text: String
//    var placeholder: String
//    
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            RoundedRectangle(cornerRadius: 5)
//                .stroke(.syncBlack, lineWidth: 2)
//            
//            TextEditor(text: $text)
//                .bodyTextStyle()
//                .scrollContentBackground(.hidden)
//                .foregroundStyle(.syncBlack)
//            
//            if text.isEmpty {
//                Text(placeholder)
//                    .h2Style()
//                    .foregroundStyle(.syncGrey)
//                    .italic()
//                    .padding(.top, 10)
//                    .padding(.leading, 5)
//            }
//        }
//    }
//}
struct CustomOnBoardingTextEditor: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 5)
                .stroke(.syncBlack, lineWidth: 2)
                .frame(minHeight: 100) // Set minimum height
            
            CustomTextEditor(text: $text, placeholder: placeholder)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
        }
    }
}


struct CustomTextEditor: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .h2Style()
                    .foregroundStyle(.syncGrey)
                    .italic()
                    .padding(.top, 8) // match the TextEditor's internal padding
                    .padding(.leading, 5)
            }
            
            TextEditor(text: $text)
                .bodyTextStyle()
                .scrollContentBackground(.hidden)
                .foregroundStyle(.syncBlack)
                .frame(minHeight: 100) // Optional: adjust for expected text size
                .padding(.leading, -4) // Remove if unnecessary
        }
    }
}



struct CustomOnBoardingSecureField: View {
    var placeholder: String
    var image: String?
    @Binding var text: String
    
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let image {
                    Image(systemName: image)
                        .foregroundStyle(.syncBlack)
                        .frame(width: 20, height: 20)
                }
                if showPassword {
                    TextField("", text: $text, prompt: Text(placeholder).font(.h2).foregroundStyle(.syncGrey))
//                        .bodyTextStyle()
                        .h2Style()
                        .frame(height: 50)
                        .textInputAutocapitalization(.never)
                        .padding(.trailing, 10)
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).font(.h2).foregroundStyle(.syncGrey))
                        .foregroundStyle(.syncBlack)
                        .h2Style()
                        .frame(height: 50)
                        .padding(.trailing, 10)
                }
                
                Spacer()
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye" : "eye.slash")
                        .foregroundStyle(.syncBlack)
                }
                .frame(width: 20, height: 20)
                .padding(.trailing, 4)
            }
            Rectangle()
                .fill(.syncGrey)
                .frame(height: 2)
        }
    }
}


struct CustomOnBoardingTextField: View {
    var placeholder: String
    var image: String?
    @Binding var text: String
    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let image {
                    Image(systemName: image)
                        .foregroundStyle(.syncBlack)
                        .frame(width: 20, height: 20)
                }
                TextField("", text: $text, prompt: Text(placeholder).font(.h2).foregroundStyle(.syncGrey))
//                    .h2Style()
                    .bodyTextStyle()
                    .foregroundStyle(.syncBlack)
                    .frame(height: 50)
            }
            Rectangle()
                .fill(.syncGrey)
                .frame(height: 2)
        }
    }
}
