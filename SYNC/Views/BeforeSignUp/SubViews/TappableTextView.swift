struct TappableTextView: View {
    let fullText: String
    let tappableTexts: [String]
    let onTap: (String) -> Void
    let font: Font
    
    var body: some View {
        Text(attributedString)
            .multilineTextAlignment(.center)
            .font(font)
            .tint(.syncBlack)
            .foregroundStyle(.syncBlack)
            .environment(\.openURL, OpenURLAction { url in
                // Extract the tapped text from the URL scheme
                if url.scheme == "tappable",
                   let tappedText = url.host {
                    // Decode the URL-encoded text back to original
                    let decodedText = tappedText.removingPercentEncoding ?? tappedText
                    onTap(decodedText)
                }
                return .handled
            })
    }
    
    private var attributedString: AttributedString {
        var attributedString = AttributedString(fullText)
        
        for tappableText in tappableTexts {
            if let range = attributedString.range(of: tappableText) {
                attributedString[range].font = Font.custom("Poppins-Regular", size: 12).bold()
                attributedString[range].foregroundColor = .syncBlack
                // Create a proper URL with custom scheme
                if let encodedText = tappableText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                   let url = URL(string: "tappable://\(encodedText)") {
                    attributedString[range].link = url
                }
            }
        }
        
        return attributedString
    }
}