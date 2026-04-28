import Foundation

struct WorkAction: Identifiable, Hashable, Codable {
    var id = UUID()
    var text: String
    var timestamp: Date = .now
}
