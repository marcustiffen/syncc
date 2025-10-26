import Foundation
import SwiftUI




struct DynamicGridView<Item: Identifiable & Equatable>: View {
    @EnvironmentObject var subscriptionmodel: SubscriptionModel
    var isSubscriptionActive: Bool
    
    @Binding var selectedItems: [Item]
    @Binding var showPayWallView: Bool
    
    var items: [Item]
    var itemContent: (Item) -> InterestPillView

    var body: some View {
        WrappingHStack(items: items) { item in
            itemContent(item)
                .onTapGesture {
                    if isSubscriptionActive {
                        if !selectedItems.contains(where: { $0 == item }) && selectedItems.count < 5 {
                            selectedItems.append(item)
                        } else {
                            selectedItems.removeAll(where: { $0 == item })
                        }
                    } else {
                        showPayWallView = true
                    }
                }
        }
    }
}
