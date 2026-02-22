import SwiftUI

struct SudokuGridView: View {
    @Bindable var viewModel: SudokuGameViewModel

    var body: some View {
        let cellSize = calculateCellSize()
        let gridSize = viewModel.gridSize
        let boxRows = viewModel.boxRows
        let boxCols = viewModel.boxCols

        VStack(spacing: 0) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let isSelected = viewModel.selectedRow == row && viewModel.selectedCol == col
                        let isSameRowOrCol = (viewModel.selectedRow == row || viewModel.selectedCol == col)
                            && !isSelected
                        let isSameBox: Bool = {
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            return viewModel.isInSameBox(row1: row, col1: col, row2: sr, col2: sc) && !isSelected
                        }()
                        let isSameNumber: Bool = {
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            let selectedVal = viewModel.grid[sr][sc]
                            return selectedVal != 0 && viewModel.grid[row][col] == selectedVal && !isSelected
                        }()
                        let isWrong = viewModel.wrongCell?.row == row && viewModel.wrongCell?.col == col

                        SudokuCellView(
                            row: row,
                            col: col,
                            value: viewModel.grid[row][col],
                            isPrefilled: viewModel.prefilled[row][col],
                            isSelected: isSelected,
                            isSameRowOrCol: isSameRowOrCol,
                            isSameBox: isSameBox,
                            isSameNumber: isSameNumber,
                            isWrong: isWrong,
                            cellSize: cellSize,
                            gridSize: gridSize
                        )
                        .onTapGesture {
                            viewModel.selectCell(row: row, col: col)
                        }

                        // Vertical thick border between boxes
                        if col < gridSize - 1 {
                            if (col + 1) % boxCols == 0 {
                                Rectangle()
                                    .fill(Color.primary)
                                    .frame(width: 2, height: cellSize)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 0.5, height: cellSize)
                            }
                        }
                    }
                }

                // Horizontal thick border between boxes
                if row < gridSize - 1 {
                    let totalWidth = CGFloat(gridSize) * cellSize
                        + CGFloat(gridSize / boxCols - 1) * 2
                        + CGFloat(gridSize - gridSize / boxCols) * 0.5
                    if (row + 1) % boxRows == 0 {
                        Rectangle()
                            .fill(Color.primary)
                            .frame(width: totalWidth, height: 2)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: totalWidth, height: 0.5)
                    }
                }
            }
        }
        .border(Color.primary, width: 2)
    }

    private func calculateCellSize() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 16
        let gridSize = CGFloat(viewModel.gridSize)
        let thickBorders = CGFloat(viewModel.gridSize / viewModel.boxCols - 1) * 2
        let thinBorders = CGFloat(viewModel.gridSize - viewModel.gridSize / viewModel.boxCols) * 0.5
        let borderWidth: CGFloat = 4 // outer border
        let available = screenWidth - padding * 2 - thickBorders - thinBorders - borderWidth
        return floor(available / gridSize)
    }
}
