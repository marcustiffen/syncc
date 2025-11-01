import SwiftUI


class MyActivityViewModel: ObservableObject {
    
}


struct MyActivityView: View {
    
    @StateObject var viewModel = MyActivityViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
