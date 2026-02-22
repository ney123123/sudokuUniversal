import SwiftUI

enum SudokuGameType: String, CaseIterable, Identifiable, Hashable {
    case classic
    case classic16
    case jigsaw
    case samurai
    case miniSamurai
    case flower
    case killer
    case windoku

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic:     return "Classic"
        case .classic16:   return "Classic 16×16"
        case .jigsaw:      return "Jigsaw"
        case .samurai:     return "Samurai"
        case .miniSamurai: return "Mini Samurai"
        case .flower:      return "Flower"
        case .killer:      return "Killer"
        case .windoku:     return "Windoku"
        }
    }

    var subtitle: String {
        switch self {
        case .classic:     return "Classic 9×9 puzzle"
        case .classic16:   return "Extended 16×16 grid"
        case .jigsaw:      return "Irregular shaped regions"
        case .samurai:     return "Five overlapping grids"
        case .miniSamurai: return "Compact overlapping grids"
        case .flower:      return "Circular overlapping layout"
        case .killer:      return "Sum-based cage puzzles"
        case .windoku:     return "Extra shaded regions"
        }
    }

    var iconName: String {
        switch self {
        case .classic:     return "square.grid.3x3"
        case .classic16:   return "square.grid.4x3.fill"
        case .jigsaw:      return "puzzlepiece.fill"
        case .samurai:     return "shield.fill"
        case .miniSamurai: return "shield.lefthalf.filled"
        case .flower:      return "camera.macro"
        case .killer:      return "target"
        case .windoku:     return "wind"
        }
    }

    var themeColor: Color {
        switch self {
        case .classic:     return .blue
        case .classic16:   return .cyan
        case .jigsaw:      return .green
        case .samurai:     return .purple
        case .miniSamurai: return .mint
        case .flower:      return .pink
        case .killer:      return .red
        case .windoku:     return .indigo
        }
    }
}
