import SwiftUI

enum OrderStatus: String, CaseIterable, Identifiable, Codable {
    case inProgress = "In Progress"
    case waiting = "Waiting"
    case completed = "Completed"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .inProgress:
            return Color(red: 0.21, green: 0.65, blue: 0.92)
        case .waiting:
            return Color(red: 0.98, green: 0.69, blue: 0.26)
        case .completed:
            return Color(red: 0.20, green: 0.77, blue: 0.49)
        }
    }

    var symbol: String {
        switch self {
        case .inProgress:
            return "wrench.and.screwdriver.fill"
        case .waiting:
            return "hourglass"
        case .completed:
            return "checkmark.seal.fill"
        }
    }
}
