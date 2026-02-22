import SwiftUI

struct RootNavigationView: View {
    @Environment(GameStateManager.self) private var gameStateManager
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(navigationPath: $navigationPath)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .gameSelection:
                        GameSelectionView(navigationPath: $navigationPath)
                    case .difficultySelection(let type):
                        DifficultySelectionView(gameType: type, navigationPath: $navigationPath)
                    case .game(let type, let difficulty):
                        switch type {
                        case .classic, .classic16:
                            SudokuGameView(gameType: type, difficulty: difficulty, navigationPath: $navigationPath)
                        default:
                            GamePlaceholderView(gameType: type)
                        }
                    }
                }
        }
    }
}

#Preview {
    RootNavigationView()
        .environment(GameStateManager())
}
