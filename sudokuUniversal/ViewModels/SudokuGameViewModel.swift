import SwiftUI
import Combine

struct SubGrid {
    let startRow: Int
    let startCol: Int
    let size: Int       // sub-grid is size × size
    let boxRows: Int
    let boxCols: Int
    let isCenter: Bool

    func contains(row: Int, col: Int) -> Bool {
        row >= startRow && row < startRow + size &&
        col >= startCol && col < startCol + size
    }
}

@Observable
final class SudokuGameViewModel {
    // MARK: - Grid Configuration
    let gridSize: Int
    let boxRows: Int
    let boxCols: Int
    let gameType: SudokuGameType
    let regions: [[Int]]?
    let subGrids: [SubGrid]
    let maxDigit: Int
    let cages: [KillerCage]?
    let cageLookup: [[Int]]?  // cageLookup[r][c] = cage index, -1 if none
    let maxCageSize: Int

    // MARK: - Puzzle State
    var grid: [[Int]]
    let solution: [[Int]]
    let prefilled: [[Bool]]

    // MARK: - Selection
    var selectedRow: Int?
    var selectedCol: Int?

    // MARK: - Lives & Status
    var livesRemaining: Int = 3
    var gameStatus: GameStatus = .playing

    // MARK: - Wrong Answer Animation
    var wrongCell: CellPosition?

    // MARK: - Timer
    var elapsedSeconds: Int = 0
    var isRunning: Bool = false
    private var timerCancellable: AnyCancellable?

    enum GameStatus {
        case playing, won, lost
    }

    struct CellPosition: Equatable {
        let row: Int
        let col: Int
    }

    // MARK: - Sub-grid definitions

    private static let flowerSubGrids: [SubGrid] = [
        SubGrid(startRow: 0, startCol: 3, size: 9, boxRows: 3, boxCols: 3, isCenter: false),
        SubGrid(startRow: 3, startCol: 0, size: 9, boxRows: 3, boxCols: 3, isCenter: false),
        SubGrid(startRow: 3, startCol: 3, size: 9, boxRows: 3, boxCols: 3, isCenter: true),
        SubGrid(startRow: 3, startCol: 6, size: 9, boxRows: 3, boxCols: 3, isCenter: false),
        SubGrid(startRow: 6, startCol: 3, size: 9, boxRows: 3, boxCols: 3, isCenter: false),
    ]

    private static let miniSamuraiSubGrids: [SubGrid] = [
        SubGrid(startRow: 0, startCol: 0, size: 4, boxRows: 2, boxCols: 2, isCenter: false),
        SubGrid(startRow: 0, startCol: 4, size: 4, boxRows: 2, boxCols: 2, isCenter: false),
        SubGrid(startRow: 4, startCol: 0, size: 4, boxRows: 2, boxCols: 2, isCenter: false),
        SubGrid(startRow: 4, startCol: 4, size: 4, boxRows: 2, boxCols: 2, isCenter: false),
        SubGrid(startRow: 2, startCol: 2, size: 4, boxRows: 2, boxCols: 2, isCenter: true),
    ]

    // MARK: - Init

    init(puzzle: SudokuPuzzle, gameType: SudokuGameType, difficulty: String = "Medium") {
        self.gameType = gameType
        self.solution = puzzle.solution
        self.regions = puzzle.regions
        self.cages = puzzle.cages

        let rows = puzzle.solution.count
        let cols = puzzle.solution[0].count
        self.gridSize = rows

        // Generate grid from puzzle or blank for killer
        let initialGrid: [[Int]]
        if let puzzleGrid = puzzle.puzzle {
            initialGrid = puzzleGrid
        } else {
            initialGrid = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        }
        self.grid = initialGrid

        // Set box dimensions and sub-grids based on game type
        switch gameType {
        case .miniSamurai:
            self.boxRows = 2
            self.boxCols = 2
            self.subGrids = Self.miniSamuraiSubGrids
            self.maxDigit = 4
        case .flower:
            self.boxRows = 3
            self.boxCols = 3
            self.subGrids = Self.flowerSubGrids
            self.maxDigit = 9
        case .classic16:
            self.boxRows = 4
            self.boxCols = 4
            self.subGrids = []
            self.maxDigit = 16
        default:
            self.boxRows = 3
            self.boxCols = 3
            self.subGrids = []
            self.maxDigit = 9
        }

        // Compute max cage size based on difficulty
        switch difficulty {
        case "Beginner": self.maxCageSize = 3
        case "Expert":   self.maxCageSize = 5
        default:         self.maxCageSize = 4
        }

        // Precompute cage lookup for killer
        if let cages = puzzle.cages {
            var lookup = Array(repeating: Array(repeating: -1, count: cols), count: rows)
            for (index, cage) in cages.enumerated() {
                for cell in cage.cells {
                    lookup[cell[0]][cell[1]] = index
                }
            }
            self.cageLookup = lookup
        } else {
            self.cageLookup = nil
        }

        // Mark prefilled cells:
        // - Non-existent cells (solution <= 0) are marked prefilled to prevent input
        // - Cells with a given value (puzzle > 0) are prefilled
        self.prefilled = (0..<rows).map { r in
            (0..<cols).map { c in
                puzzle.solution[r][c] <= 0 || initialGrid[r][c] > 0
            }
        }
    }

    // MARK: - Cell Selection

    func selectCell(row: Int, col: Int) {
        guard gameStatus == .playing else { return }
        // Reject non-existent cells
        guard solution[row][col] > 0 else { return }
        guard !prefilled[row][col] else {
            // Allow selecting prefilled cells for highlighting, but they can't be edited
            selectedRow = row
            selectedCol = col
            return
        }
        selectedRow = row
        selectedCol = col
    }

    // MARK: - Number Input

    func inputNumber(_ number: Int) {
        guard gameStatus == .playing,
              let row = selectedRow,
              let col = selectedCol,
              !prefilled[row][col],
              grid[row][col] == 0 else { return }

        if solution[row][col] == number {
            // Correct
            grid[row][col] = number
            // Deselect after correct placement
            selectedRow = nil
            selectedCol = nil
            checkWin()
        } else {
            // Wrong
            wrongCell = CellPosition(row: row, col: col)
            livesRemaining -= 1
            if livesRemaining <= 0 {
                gameStatus = .lost
                pauseTimer()
            }
            // Clear wrong cell indicator after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                self?.wrongCell = nil
            }
        }
    }

    // MARK: - Win Check

    func checkWin() {
        for row in 0..<gridSize {
            for col in 0..<grid[row].count {
                // Skip non-existent cells
                if solution[row][col] <= 0 { continue }
                if grid[row][col] == 0 {
                    return
                }
            }
        }
        gameStatus = .won
        pauseTimer()
    }

    // MARK: - Timer

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
            }
    }

    func pauseTimer() {
        isRunning = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Helpers

    func isInSameBox(row1: Int, col1: Int, row2: Int, col2: Int) -> Bool {
        // For sub-grid games (flower, miniSamurai), check sub-grid boxes
        if !subGrids.isEmpty {
            return isInSameSubGridBox(row1: row1, col1: col1, row2: row2, col2: col2)
        }
        if let regions = regions {
            return regions[row1][col1] == regions[row2][col2]
        }
        return (row1 / boxRows == row2 / boxRows) && (col1 / boxCols == col2 / boxCols)
    }

    func isInSameSubGridBox(row1: Int, col1: Int, row2: Int, col2: Int) -> Bool {
        for sg in subGrids {
            guard sg.contains(row: row1, col: col1) && sg.contains(row: row2, col: col2) else { continue }
            let localR1 = row1 - sg.startRow
            let localC1 = col1 - sg.startCol
            let localR2 = row2 - sg.startRow
            let localC2 = col2 - sg.startCol
            if (localR1 / sg.boxRows == localR2 / sg.boxRows) &&
               (localC1 / sg.boxCols == localC2 / sg.boxCols) {
                return true
            }
        }
        return false
    }

    // MARK: - Windoku Helpers

    private static let windokuWindows: [(rows: ClosedRange<Int>, cols: ClosedRange<Int>)] = [
        (1...3, 1...3),
        (1...3, 5...7),
        (5...7, 1...3),
        (5...7, 5...7),
    ]

    func isInWindokuRegion(row: Int, col: Int) -> Bool {
        Self.windokuWindows.contains { $0.rows.contains(row) && $0.cols.contains(col) }
    }

    func isInSameWindokuWindow(row1: Int, col1: Int, row2: Int, col2: Int) -> Bool {
        guard gameType == .windoku else { return false }
        return Self.windokuWindows.contains { window in
            window.rows.contains(row1) && window.cols.contains(col1) &&
            window.rows.contains(row2) && window.cols.contains(col2)
        }
    }

    func countOccurrences(of number: Int) -> Int {
        guard number > 0 else { return 0 }
        var count = 0
        for row in grid {
            for cell in row {
                if cell == number { count += 1 }
            }
        }
        return count
    }

    func isNumberFullyPlaced(_ number: Int) -> Bool {
        let target = solution.flatMap { $0 }.filter { $0 == number }.count
        return countOccurrences(of: number) >= target
    }
}
