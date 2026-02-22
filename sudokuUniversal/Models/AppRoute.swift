import Foundation

enum AppRoute: Hashable {
    case gameSelection
    case difficultySelection(SudokuGameType)
    case game(SudokuGameType, String) // gameType + difficulty name
}
