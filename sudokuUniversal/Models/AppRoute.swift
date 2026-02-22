import Foundation

enum AppRoute: Hashable {
    case gameSelection
    case game(SudokuGameType)
}
