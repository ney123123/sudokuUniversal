import SwiftUI

struct SudokuGridView: View {
    @Bindable var viewModel: SudokuGameViewModel

    private static let regionColors: [Color] = [
        Color.green.opacity(0.3),
        Color.orange.opacity(0.3),
        Color.purple.opacity(0.3),
        Color.yellow.opacity(0.3),
        Color.pink.opacity(0.3),
        Color.teal.opacity(0.3),
        Color.indigo.opacity(0.3),
        Color.mint.opacity(0.3),
        Color.brown.opacity(0.3),
        Color.cyan.opacity(0.3),
        Color.gray.opacity(0.3),
    ]

    var body: some View {
        let gridSize = viewModel.gridSize
        let vBorderWidths = computeVerticalBorderWidths()
        let hBorderHeights = computeHorizontalBorderHeights()
        let cellSize = calculateCellSize(vBorderWidths: vBorderWidths)

        VStack(spacing: 0) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        let isSelected = viewModel.selectedRow == row && viewModel.selectedCol == col
                        let isSameRowOrCol = (viewModel.selectedRow == row || viewModel.selectedCol == col)
                            && !isSelected
                        let isSameBox: Bool = {
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            if isSelected { return false }
                            if viewModel.isInSameBox(row1: row, col1: col, row2: sr, col2: sc) { return true }
                            if viewModel.isInSameWindokuWindow(row1: row, col1: col, row2: sr, col2: sc) { return true }
                            return false
                        }()
                        let isSameNumber: Bool = {
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            let selectedVal = viewModel.grid[sr][sc]
                            return selectedVal != 0 && viewModel.grid[row][col] == selectedVal && !isSelected
                        }()
                        let isWrong = viewModel.wrongCell?.row == row && viewModel.wrongCell?.col == col

                        let regionColor: Color? = {
                            guard let regions = viewModel.regions else { return nil }
                            let regionId = regions[row][col]
                            return Self.regionColors[regionId % Self.regionColors.count]
                        }()

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
                            gridSize: gridSize,
                            regionColor: regionColor
                        )
                        .onTapGesture {
                            viewModel.selectCell(row: row, col: col)
                        }

                        // Vertical border
                        if col < gridSize - 1 {
                            let spaceWidth = vBorderWidths[col]
                            let isThick = isThickVerticalBorder(row: row, col: col)
                            (isThick ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: isThick ? spaceWidth : 0.5, height: cellSize)
                                .frame(width: spaceWidth, height: cellSize)
                        }
                    }
                }

                // Horizontal border row
                if row < gridSize - 1 {
                    HStack(spacing: 0) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            let spaceHeight = hBorderHeights[row]
                            let isThick = isThickHorizontalBorder(row: row, col: col)
                            (isThick ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: cellSize, height: isThick ? spaceHeight : 0.5)
                                .frame(width: cellSize, height: spaceHeight)

                            // Corner fill
                            if col < gridSize - 1 {
                                let cornerW = vBorderWidths[col]
                                let cornerH = hBorderHeights[row]
                                let vThick = isThickVerticalBorder(row: row, col: col)
                                    || isThickVerticalBorder(row: row + 1, col: col)
                                let hThick = isThickHorizontalBorder(row: row, col: col)
                                    || isThickHorizontalBorder(row: row, col: col + 1)
                                ((vThick || hThick) ? Color.primary : Color.gray.opacity(0.3))
                                    .frame(width: cornerW, height: cornerH)
                            }
                        }
                    }
                }
            }
        }
        .border(Color.primary, width: 2)
        .overlay(alignment: .topLeading) {
            if viewModel.gameType == .windoku {
                windokuOverlay(cellSize: cellSize, vBorderWidths: vBorderWidths, hBorderHeights: hBorderHeights)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Border Logic

    private func isThickVerticalBorder(row: Int, col: Int) -> Bool {
        if let regions = viewModel.regions {
            return regions[row][col] != regions[row][col + 1]
        }
        return (col + 1) % viewModel.boxCols == 0
    }

    private func isThickHorizontalBorder(row: Int, col: Int) -> Bool {
        if let regions = viewModel.regions {
            return regions[row][col] != regions[row + 1][col]
        }
        return (row + 1) % viewModel.boxRows == 0
    }

    private func computeVerticalBorderWidths() -> [CGFloat] {
        let gridSize = viewModel.gridSize
        guard gridSize > 1 else { return [] }
        var widths = [CGFloat](repeating: 0.5, count: gridSize - 1)

        if let regions = viewModel.regions {
            for col in 0..<(gridSize - 1) {
                for row in 0..<gridSize {
                    if regions[row][col] != regions[row][col + 1] {
                        widths[col] = 2
                        break
                    }
                }
            }
        } else {
            for col in 0..<(gridSize - 1) {
                widths[col] = (col + 1) % viewModel.boxCols == 0 ? 2 : 0.5
            }
        }

        return widths
    }

    private func computeHorizontalBorderHeights() -> [CGFloat] {
        let gridSize = viewModel.gridSize
        guard gridSize > 1 else { return [] }
        var heights = [CGFloat](repeating: 0.5, count: gridSize - 1)

        if let regions = viewModel.regions {
            for row in 0..<(gridSize - 1) {
                for col in 0..<gridSize {
                    if regions[row][col] != regions[row + 1][col] {
                        heights[row] = 2
                        break
                    }
                }
            }
        } else {
            for row in 0..<(gridSize - 1) {
                heights[row] = (row + 1) % viewModel.boxRows == 0 ? 2 : 0.5
            }
        }

        return heights
    }

    // MARK: - Cell Size

    private func calculateCellSize(vBorderWidths: [CGFloat]) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let padding: CGFloat = 16
        let gridSize = CGFloat(viewModel.gridSize)
        let totalBorderWidth = vBorderWidths.reduce(CGFloat(0), +)
        let outerBorderWidth: CGFloat = 4
        let available = screenWidth - padding * 2 - totalBorderWidth - outerBorderWidth
        return floor(available / gridSize)
    }

    // MARK: - Windoku Overlay

    private func windokuOverlay(cellSize: CGFloat, vBorderWidths: [CGFloat], hBorderHeights: [CGFloat]) -> some View {
        let windows: [(startRow: Int, startCol: Int, endRow: Int, endCol: Int)] = [
            (1, 1, 3, 3),
            (1, 5, 3, 7),
            (5, 1, 7, 3),
            (5, 5, 7, 7),
        ]

        return ZStack(alignment: .topLeading) {
            Color.clear
            ForEach(0..<windows.count, id: \.self) { i in
                let window = windows[i]
                let x = gridXOffset(col: window.startCol, cellSize: cellSize, vBorderWidths: vBorderWidths)
                let y = gridYOffset(row: window.startRow, cellSize: cellSize, hBorderHeights: hBorderHeights)
                let endX = gridXOffset(col: window.endCol, cellSize: cellSize, vBorderWidths: vBorderWidths) + cellSize
                let endY = gridYOffset(row: window.endRow, cellSize: cellSize, hBorderHeights: hBorderHeights) + cellSize

                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: endX - x, height: endY - y)
                    .offset(x: x, y: y)
            }
        }
    }

    private func gridXOffset(col: Int, cellSize: CGFloat, vBorderWidths: [CGFloat]) -> CGFloat {
        var x: CGFloat = 0
        for c in 0..<col {
            x += cellSize
            if c < vBorderWidths.count {
                x += vBorderWidths[c]
            }
        }
        return x
    }

    private func gridYOffset(row: Int, cellSize: CGFloat, hBorderHeights: [CGFloat]) -> CGFloat {
        var y: CGFloat = 0
        for r in 0..<row {
            y += cellSize
            if r < hBorderHeights.count {
                y += hBorderHeights[r]
            }
        }
        return y
    }
}
