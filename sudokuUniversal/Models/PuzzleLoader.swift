import Foundation

struct PuzzleLoader {
    static func jsonFilename(for gameType: SudokuGameType) -> String? {
        switch gameType {
        case .classic:      return "sudoku"
        case .classic16:    return "sudoku_16"
        case .jigsaw:       return "sudoku_jigsaw"
        case .windoku:      return "sudoku_windoku"
        case .killer:       return "sudoku_killer"
        case .flower:       return "sudoku_flower"
        case .miniSamurai:  return "sudoku_samurai_4"
        default:            return nil
        }
    }

    static func loadPuzzles(for gameType: SudokuGameType) -> [SudokuPuzzle] {
        guard let filename = jsonFilename(for: gameType),
              let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let collection = try JSONDecoder().decode(SudokuPuzzleCollection.self, from: data)
            return collection.puzzles
        } catch {
            print("Failed to load puzzles: \(error)")
            return []
        }
    }

    static func availableDifficulties(for gameType: SudokuGameType) -> [String] {
        let puzzles = loadPuzzles(for: gameType)
        var seen = Set<String>()
        var ordered: [String] = []
        for puzzle in puzzles.sorted(by: { $0.difficulty < $1.difficulty }) {
            if seen.insert(puzzle.difficulty_name).inserted {
                ordered.append(puzzle.difficulty_name)
            }
        }
        return ordered
    }

    static func loadPuzzle(for gameType: SudokuGameType, difficulty: String) -> SudokuPuzzle? {
        let puzzles = loadPuzzles(for: gameType)
        let matching = puzzles.filter { $0.difficulty_name == difficulty }
        return matching.randomElement()
    }
}
