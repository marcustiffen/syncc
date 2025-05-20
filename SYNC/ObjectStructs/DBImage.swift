import Foundation
import PhotosUI
import SwiftUI


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
