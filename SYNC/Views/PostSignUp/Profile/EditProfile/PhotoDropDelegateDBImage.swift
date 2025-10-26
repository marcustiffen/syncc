import SwiftUI
import PhotosUI

struct PhotoDropDelegateDBImage: DropDelegate {
    let item: DBImage
    let items: [DBImage]
    let completion: (_ draggedItem: DBImage, _ destinationIndex: Int) -> Void

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedItem = info.itemProviders(for: [.text]).first else { return false }

        draggedItem.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, _) in
            DispatchQueue.main.async {
                var urlString: String?

                if let str = data as? String {
                    urlString = str
                } else if let data = data as? Data {
                    urlString = String(data: data, encoding: .utf8)
                }

                guard let url = urlString,
                      let dragged = items.first(where: { $0.url == url }),
                      let destinationIndex = items.firstIndex(of: item)
                else {
                    print("⚠️ Failed to resolve dragged item from drop")
                    return
                }

                completion(dragged, destinationIndex)
            }
        }

        return true
    }

}
