import SwiftUI

struct GamePlaceholderView: View {
    let gameType: SudokuGameType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: gameType.iconName)
                .font(.system(size: 80))
                .foregroundStyle(gameType.themeColor.gradient)

            Text(gameType.displayName)
                .font(.largeTitle.bold())

            Text("Game board coming soon")
                .foregroundStyle(.secondary)
        }
        .navigationTitle(gameType.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GamePlaceholderView(gameType: .classic)
    }
}
