import EventKit
import MapKit
import SwiftUI


struct CalendarSuccessView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.syncGreen.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.syncGreen)
            }
            
            VStack(spacing: 8) {
                Text("Added to Calendar!")
                    .h1Style()
                    .foregroundStyle(.syncBlack)
                
                Text("You'll get a reminder when it's time")
                    .bodyTextStyle()
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button {
                isPresented = false
            } label: {
                Text("Done")
                    .h2Style()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.syncBlack)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(.top, 20)
    }
}
