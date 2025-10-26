import SwiftUI


struct ImageEditorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileModel: ProfileModel
    
    @Binding var imageBeingEdited: DBImage
    var onSave: () -> Void
    
    @State private var currentOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Image editor area
            GeometryReader { geo in
                let screenWidth = geo.size.width
                let screenHeight = geo.size.width * 1.2
                
                ZStack(alignment: .center) {
                    // Full-screen image (darkened outside the crop area)
//                    ImageLoaderView(urlString: imageBeingEdited.url)
//                        .offset(currentOffset)
//                        .scaleEffect(currentScale)
//                        .clipped()
                    ImageLoaderView(urlString: imageBeingEdited.url)
//                        .scaledToFill() // Add this to match the initial sizing in ImageSelectorView
                        .frame(width: screenWidth, height: screenHeight) // Constrain the frame
                        .offset(currentOffset)
                        .scaleEffect(currentScale)
                        .clipped()
                        .overlay(
                            // Dark overlay with transparent "window"
                            ZStack {
                                // Fully dark background
                                Color.black.opacity(0.7)
                                    .frame(width: geo.size.width, height: geo.size.height)
                                
                                // Transparent "window"
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: screenWidth, height: screenHeight)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                        )
                    
                    
                    // Gestures for panning and zooming
                    Color.clear
                        .frame(width: screenWidth, height: screenHeight)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.currentOffset = CGSize(
                                        width: value.translation.width + (imageBeingEdited.offsetX.width),
                                        height: value.translation.height + (imageBeingEdited.offsetY.height)
                                    )
                                }
                                .onEnded { value in
                                    // Store the final offset when drag ends
                                    self.currentOffset = CGSize(
                                        width: value.translation.width + (imageBeingEdited.offsetX.width),
                                        height: value.translation.height + (imageBeingEdited.offsetY.height)
                                    )
                                    imageBeingEdited.offsetX = CGSize(width: currentOffset.width, height: 0)
                                    imageBeingEdited.offsetY = CGSize(width: 0, height: currentOffset.height)
                                    imageBeingEdited.scale = currentScale
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let scaleFactor = imageBeingEdited.scale * value
                                    self.currentScale = scaleFactor
                                }
                                .onEnded { value in
                                    let scaleFactor = imageBeingEdited.scale * value
                                    self.currentScale = scaleFactor
                                    imageBeingEdited.offsetX = CGSize(width: currentOffset.width, height: 0)
                                    imageBeingEdited.offsetY = CGSize(width: 0, height: currentOffset.height)
                                    imageBeingEdited.scale = currentScale
                                }
                        )
                    
                    // Border for the crop window
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: screenWidth, height: screenHeight)
                        .allowsHitTesting(false)
                    
                    // Add help text at the bottom
                    VStack {
                        Spacer()
                        Text("Pinch to zoom • Drag to position")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.bottom, 30)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            
            // Bottom action buttons
            HStack(spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button {
                    // Update the image with new position and scale
                    imageBeingEdited.offsetX = CGSize(width: currentOffset.width, height: 0)
                    imageBeingEdited.offsetY = CGSize(width: 0, height: currentOffset.height)
                    imageBeingEdited.scale = currentScale
                    
                    // Call the onSave callback
                    onSave()
                    
                    // Dismiss the view
                    dismiss()
                } label: {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
            .background(Color.white)
        }
        .padding(.horizontal, 10)
        .onAppear {
            // Initialize with current values
            currentOffset = CGSize(
                width: imageBeingEdited.offsetX.width,
                height: imageBeingEdited.offsetY.height
            )
            currentScale = imageBeingEdited.scale
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

