import SwiftUI


//struct ProfileOptionView: View {
//    let icon: String
//    let title: String
//    var color: Color = .black
//    var destination: AnyView? = nil
//    var action: (() -> Void)? = nil
//    
//    var body: some View {
//        Group {
//            if let destination = destination {
//                NavigationLink(destination: destination) {
//                    optionContent
//                }
//            } else {
//                Button(action: action ?? {}) {
//                    optionContent
//                }
//            }
//        }
//    }
//    
//    private var optionContent: some View {
//        HStack {
//            Image(systemName: icon)
//                .foregroundColor(color)
//                .frame(width: 30)
//            
//            Text(title)
//                .foregroundColor(color)
//            
//            Spacer()
//            if action == nil {
//                Image(systemName: "chevron.right")
//                    .foregroundColor(.gray)
//            }
//        }
//        .h2Style()
//        .padding()
//        .background(Color.gray.opacity(0.1))
//        .cornerRadius(12)
//    }
//}



struct ProfileOptionView<Destination: View>: View {
    let icon: String
    let title: String
    var color: Color = .black
    var destination: Destination?
    var action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        color: Color = .black,
        destination: Destination? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.destination = destination
        self.action = action
    }
    
    var body: some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    optionContent
                }
            } else {
                Button(action: action ?? {}) {
                    optionContent
                }
            }
        }
    }
    
    private var optionContent: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(color)
            
            Spacer()
            if action == nil {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .h2Style()
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// For button-only options without destinations
extension ProfileOptionView where Destination == EmptyView {
    init(
        icon: String,
        title: String,
        color: Color = .black,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.destination = nil
        self.action = action
    }
}
