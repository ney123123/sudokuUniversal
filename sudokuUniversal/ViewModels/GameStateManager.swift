import SwiftUI

@Observable
final class GameStateManager {
    var hasUnfinishedGame: Bool = false
    var currentGameType: SudokuGameType? = nil

    func checkForUnfinishedGame() {
        // Placeholder: will query Core Data for an active game session
        hasUnfinishedGame = false
    }

    var currentDifficulty: String? = nil

    func resumeRoute() -> AppRoute? {
        guard hasUnfinishedGame, let gameType = currentGameType, let difficulty = currentDifficulty else { return nil }
        return .game(gameType, difficulty)
    }
}
