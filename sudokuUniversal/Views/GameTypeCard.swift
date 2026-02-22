import SwiftUI

struct GameTypeCard: View {
    let gameType: SudokuGameType
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: gameType.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)

                VStack(spacing: 4) {
                    Text(gameType.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(gameType.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gameType.themeColor.gradient)
            )
            .shadow(color: gameType.themeColor.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    HStack(spacing: 16) {
        GameTypeCard(gameType: .classic) {}
        GameTypeCard(gameType: .killer) {}
    }
    .padding()
}
