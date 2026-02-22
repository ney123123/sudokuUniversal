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
                    case .game(let type):
                        GamePlaceholderView(gameType: type)
                    }
                }
        }
    }
}

#Preview {
    RootNavigationView()
        .environment(GameStateManager())
}
