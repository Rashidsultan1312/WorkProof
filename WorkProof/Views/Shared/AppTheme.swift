import SwiftUI

enum AppTheme {
    static let pageGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.09, blue: 0.17),
            Color(red: 0.09, green: 0.19, blue: 0.29),
            Color(red: 0.11, green: 0.26, blue: 0.36)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color.white.opacity(0.12)
    static let strongCardBackground = Color.white.opacity(0.18)
    static let line = Color.white.opacity(0.14)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.76)

    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 0.31, green: 0.91, blue: 0.85),
            Color(red: 0.27, green: 0.71, blue: 1.0)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension View {
    func frostedCard(cornerRadius: CGFloat = 24) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.line, lineWidth: 1)
            )
    }
}
