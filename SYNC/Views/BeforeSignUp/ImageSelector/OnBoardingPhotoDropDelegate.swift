import SwiftUI



struct OnBoardingPhotoDropDelegate: DropDelegate {
    let destinationIndex: Int
    @Binding var draggedIndex: Int?
    @Binding var items: [UIImage]
    
    func performDrop(info: DropInfo) -> Bool {
        guard let draggedIndex = self.draggedIndex else { return false }
        
        withAnimation {
            let draggedItem = items[draggedIndex]
            items.remove(at: draggedIndex)
            items.insert(draggedItem, at: destinationIndex)
        }
        
        self.draggedIndex = nil
        return true
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
