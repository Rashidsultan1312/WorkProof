import SwiftUI

struct StatusChip: View {
    let status: OrderStatus
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: status.symbol)
                .font(.system(size: 12, weight: .bold))
            Text(status.rawValue)
                .font(.custom("AvenirNext-DemiBold", size: 13))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(isSelected ? status.color.opacity(0.9) : status.color.opacity(0.28))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.white.opacity(isSelected ? 0.45 : 0.15), lineWidth: 1)
        )
    }
}
