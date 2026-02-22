import Foundation

struct SudokuPuzzleCollection: Codable {
    let puzzles: [SudokuPuzzle]
}

struct SudokuPuzzle: Codable, Identifiable {
    let id: Int
    let difficulty: Int
    let difficulty_name: String
    let puzzle: [[Int]]
    let solution: [[Int]]
    let regions: [[Int]]?
}
