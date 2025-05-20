import Foundation
import SwiftUI

struct WrappingHStack<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let spacing: CGFloat
    let content: (Item) -> Content
    
    init(items: [Item], spacing: CGFloat = 8, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                self.generateContent(in: geometry.size.width)
            }
        }
    }
    
    private func generateContent(in width: CGFloat) -> some View {
        var currentRowWidth: CGFloat = 0
        var rows: [[Item]] = [[]]
        
        for item in items {
            let itemView = content(item)
            let viewWidth = UIHostingController(rootView: itemView).view.intrinsicContentSize.width
            
            if currentRowWidth + viewWidth + spacing > width {
                rows.append([item])
                currentRowWidth = viewWidth
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += viewWidth + spacing
            }
        }
        
        return VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(rows[rowIndex]) { item in
                        content(item)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
