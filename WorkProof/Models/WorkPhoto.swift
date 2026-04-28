import Foundation

struct WorkPhoto: Identifiable, Hashable, Codable {
    var id = UUID()
    var stage: PhotoStage
    var timestamp: Date = .now
    var imageData: Data
}
