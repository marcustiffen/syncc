import FirebaseAuth
import FirebaseStorage
import SwiftUI
import PhotosUI


struct LoadingPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.syncGrey)
                .frame(width: 100, height: 100)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
        }
        .transition(.scale(scale: 0.8))
    }
}
