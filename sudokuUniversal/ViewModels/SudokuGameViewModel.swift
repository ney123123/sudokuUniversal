import SwiftUI
import Combine

@Observable
final class SudokuGameViewModel {
    // MARK: - Grid Configuration
    let gridSize: Int
    let boxRows: Int
    let boxCols: Int
    let gameType: SudokuGameType
    let regions: [[Int]]?

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

    // MARK: - Init

    init(puzzle: SudokuPuzzle, gameType: SudokuGameType) {
        self.gameType = gameType
        self.solution = puzzle.solution
        self.grid = puzzle.puzzle

        let size = puzzle.puzzle.count
        self.gridSize = size

        if size == 16 {
            self.boxRows = 4
            self.boxCols = 4
        } else {
            self.boxRows = 3
            self.boxCols = 3
        }

        self.regions = puzzle.regions

        // Mark prefilled cells (non-zero in original puzzle)
        self.prefilled = puzzle.puzzle.map { row in
            row.map { $0 != 0 }
        }
    }

    // MARK: - Cell Selection

    func selectCell(row: Int, col: Int) {
        guard gameStatus == .playing else { return }
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
            for col in 0..<gridSize {
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
        if let regions = regions {
            return regions[row1][col1] == regions[row2][col2]
        }
        return (row1 / boxRows == row2 / boxRows) && (col1 / boxCols == col2 / boxCols)
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
        return countOccurrences(of: number) >= gridSize
    }
}
