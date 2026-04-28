import Foundation
import UIKit

enum ImageOptimizationService {
    static func optimizedImageData(
        from sourceData: Data,
        maxDimension: CGFloat = 1600,
        compressionQuality: CGFloat = 0.76
    ) -> Data {
        guard let image = UIImage(data: sourceData) else {
            return sourceData
        }

        let sourceSize = image.size
        let longestSide = max(sourceSize.width, sourceSize.height)
        let scale = longestSide > maxDimension ? maxDimension / longestSide : 1
        let targetSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)

        guard scale < 1 else {
            if sourceData.count <= 1_000_000 {
                return sourceData
            }
            return image.jpegData(compressionQuality: compressionQuality) ?? sourceData
        }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return rendered.jpegData(compressionQuality: compressionQuality) ?? sourceData
    }
}
