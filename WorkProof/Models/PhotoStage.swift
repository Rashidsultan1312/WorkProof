import Foundation

enum PhotoStage: String, CaseIterable, Identifiable, Codable {
    case before = "Before"
    case inProgress = "In Progress"
    case after = "After"

    var id: String { rawValue }
}
