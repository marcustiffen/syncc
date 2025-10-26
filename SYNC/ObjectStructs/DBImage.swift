import Foundation
import PhotosUI
import SwiftUI


//struct DBImage: Codable, Hashable {
//    var url: String
//    var uiImage: UIImage
//    var offsetX: CGSize
//    var offsetY: CGSize
//    var scale: CGFloat
//    
//    // Add this initializer
//    init(url: String, uiImage: UIImage, offsetX: CGSize, offsetY: CGSize, scale: CGFloat) {
//        self.url = url
//        self.uiImage = uiImage
//        self.offsetX = offsetX
//        self.offsetY = offsetY
//        self.scale = scale
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case url, offsetX, offsetY, scale
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.url = try container.decode(String.self, forKey: .url)
//        self.uiImage = UIImage()
//        self.offsetX = try container.decode(CGSize.self, forKey: .offsetX)
//        self.offsetY = try container.decode(CGSize.self, forKey: .offsetY)
//        self.scale = try container.decode(CGFloat.self, forKey: .scale)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(url, forKey: .url)
//        try container.encode(offsetX, forKey: .offsetX)
//        try container.encode(offsetY, forKey: .offsetY)
//        try container.encode(scale, forKey: .scale)
//    }
//}
//
//
//extension DBImage {
//    func toFirestoreData() -> [String: Any] {
//        return [
//            "url": url,
//            "uiImage": uiImage,
//            "offsetX": offsetX,
//            "offsetY": offsetY,
//            "scale": scale
//        ]
//    }
//}
struct DBImage: Codable, Hashable {
    var url: String
    var uiImage: UIImage
    var offsetX: CGSize
    var offsetY: CGSize
    var scale: CGFloat
    
    // Add this initializer
    init(url: String, uiImage: UIImage, offsetX: CGSize, offsetY: CGSize, scale: CGFloat) {
        self.url = url
        self.uiImage = uiImage
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.scale = scale
    }
    
    // Initializer from Firestore data
    init(from firestoreData: [String: Any]) {
        self.url = firestoreData["url"] as? String ?? ""
        self.uiImage = UIImage() // Will be loaded separately from URL

        // Handle offsetX as array
        if let offsetXArray = firestoreData["offsetX"] as? [Double], offsetXArray.count == 2 {
            self.offsetX = CGSize(width: offsetXArray[0], height: offsetXArray[1])
        } else {
            self.offsetX = .zero
        }

        // Handle offsetY as array
        if let offsetYArray = firestoreData["offsetY"] as? [Double], offsetYArray.count == 2 {
            self.offsetY = CGSize(width: offsetYArray[0], height: offsetYArray[1])
        } else {
            self.offsetY = .zero
        }

        self.scale = firestoreData["scale"] as? CGFloat ?? 1.0
    }
    
    enum CodingKeys: String, CodingKey {
        case url, offsetX, offsetY, scale
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.uiImage = UIImage()
        self.offsetX = try container.decode(CGSize.self, forKey: .offsetX)
        self.offsetY = try container.decode(CGSize.self, forKey: .offsetY)
        self.scale = try container.decode(CGFloat.self, forKey: .scale)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(offsetX, forKey: .offsetX)
        try container.encode(offsetY, forKey: .offsetY)
        try container.encode(scale, forKey: .scale)
    }
}

extension DBImage {
    func toFirestoreData() -> [String: Any] {
        return [
            "url": url,
            "offsetX": [offsetX.width, offsetX.height],
            "offsetY": [offsetY.width, offsetY.height],
            "scale": scale
        ]
    }
    
    static func arrayToFirestoreData(_ images: [DBImage]) -> [[String: Any]] {
        return images.map { $0.toFirestoreData() }
    }
}
