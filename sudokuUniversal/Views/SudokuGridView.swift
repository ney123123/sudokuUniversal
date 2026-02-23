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
        let colCount = viewModel.solution[0].count
        let vBorderWidths = computeVerticalBorderWidths()
        let hBorderHeights = computeHorizontalBorderHeights()
        let cellSize = calculateCellSize(vBorderWidths: vBorderWidths)

        VStack(spacing: 0) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<colCount, id: \.self) { col in
                        let isNonExistent = viewModel.solution[row][col] <= 0

                        let isSelected = !isNonExistent && viewModel.selectedRow == row && viewModel.selectedCol == col
                        let isSameRowOrCol: Bool = {
                            guard !isNonExistent else { return false }
                            return (viewModel.selectedRow == row || viewModel.selectedCol == col)
                                && !isSelected
                        }()
                        let isSameBox: Bool = {
                            guard !isNonExistent else { return false }
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            if isSelected { return false }
                            if viewModel.isInSameBox(row1: row, col1: col, row2: sr, col2: sc) { return true }
                            if viewModel.isInSameWindokuWindow(row1: row, col1: col, row2: sr, col2: sc) { return true }
                            return false
                        }()
                        let isSameNumber: Bool = {
                            guard !isNonExistent else { return false }
                            guard let sr = viewModel.selectedRow, let sc = viewModel.selectedCol else { return false }
                            let selectedVal = viewModel.grid[sr][sc]
                            return selectedVal != 0 && viewModel.grid[row][col] == selectedVal && !isSelected
                        }()
                        let isWrong = viewModel.wrongCell?.row == row && viewModel.wrongCell?.col == col

                        let regionColor: Color? = {
                            guard !isNonExistent else { return nil }
                            guard let regions = viewModel.regions else { return nil }
                            let regionId = regions[row][col]
                            return Self.regionColors[regionId % Self.regionColors.count]
                        }()

                        let cageSum: Int? = computeCageSum(row: row, col: col)
                        let cageBorders = computeCageBorders(row: row, col: col)
                        let isCageHighlighted: Bool = {
                            guard let cageLookup = viewModel.cageLookup,
                                  let cages = viewModel.cages,
                                  let sr = viewModel.selectedRow,
                                  let sc = viewModel.selectedCol else { return false }
                            let selectedCage = cageLookup[sr][sc]
                            guard selectedCage >= 0 else { return false }
                            let cellCage = cageLookup[row][col]
                            return cellCage == selectedCage && cages[selectedCage].cells.count > 1 && cages[selectedCage].cells.count <= viewModel.maxCageSize
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
                            regionColor: regionColor,
                            isNonExistent: isNonExistent,
                            cageSum: cageSum,
                            cageBorders: cageBorders,
                            isCageHighlighted: isCageHighlighted
                        )
                        .onTapGesture {
                            viewModel.selectCell(row: row, col: col)
                        }

                        // Vertical border
                        if col < colCount - 1 {
                            let spaceWidth = vBorderWidths[col]
                            let leftNonExistent = viewModel.solution[row][col] <= 0
                            let rightNonExistent = viewModel.solution[row][col + 1] <= 0
                            let isThick = isThickVerticalBorder(row: row, col: col)

                            if leftNonExistent && rightNonExistent {
                                Color.clear
                                    .frame(width: spaceWidth, height: cellSize)
                            } else if leftNonExistent || rightNonExistent {
                                Color.clear
                                    .frame(width: spaceWidth, height: cellSize)
                            } else {
                                (isThick ? Color.primary : Color.gray.opacity(0.3))
                                    .frame(width: isThick ? spaceWidth : 0.5, height: cellSize)
                                    .frame(width: spaceWidth, height: cellSize)
                            }
                        }
                    }
                }

                // Horizontal border row
                if row < gridSize - 1 {
                    HStack(spacing: 0) {
                        ForEach(0..<colCount, id: \.self) { col in
                            let spaceHeight = hBorderHeights[row]
                            let topNonExistent = viewModel.solution[row][col] <= 0
                            let bottomNonExistent = viewModel.solution[row + 1][col] <= 0
                            let isThick = isThickHorizontalBorder(row: row, col: col)

                            if topNonExistent && bottomNonExistent {
                                Color.clear
                                    .frame(width: cellSize, height: spaceHeight)
                            } else if topNonExistent || bottomNonExistent {
                                Color.clear
                                    .frame(width: cellSize, height: spaceHeight)
                            } else {
                                (isThick ? Color.primary : Color.gray.opacity(0.3))
                                    .frame(width: cellSize, height: isThick ? spaceHeight : 0.5)
                                    .frame(width: cellSize, height: spaceHeight)
                            }

                            // Corner fill
                            if col < colCount - 1 {
                                let cornerW = vBorderWidths[col]
                                let cornerH = hBorderHeights[row]
                                // Check if any adjacent cell is non-existent
                                let anyNonExistent =
                                    viewModel.solution[row][col] <= 0 ||
                                    viewModel.solution[row][col + 1] <= 0 ||
                                    viewModel.solution[row + 1][col] <= 0 ||
                                    viewModel.solution[row + 1][col + 1] <= 0

                                if anyNonExistent {
                                    Color.clear
                                        .frame(width: cornerW, height: cornerH)
                                } else {
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
        }
        .border(Color.primary, width: viewModel.gameType == .flower || viewModel.gameType == .miniSamurai ? 0 : 2)
        .overlay(alignment: .topLeading) {
            if viewModel.gameType == .windoku {
                windokuOverlay(cellSize: cellSize, vBorderWidths: vBorderWidths, hBorderHeights: hBorderHeights)
                    .allowsHitTesting(false)
            }
            if viewModel.gameType == .flower || viewModel.gameType == .miniSamurai {
                subGridOverlay(cellSize: cellSize, vBorderWidths: vBorderWidths, hBorderHeights: hBorderHeights)
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Border Logic

    private func isThickVerticalBorder(row: Int, col: Int) -> Bool {
        let colCount = viewModel.solution[0].count
        guard col + 1 < colCount else { return false }
        // If either cell is non-existent, no thick border
        if viewModel.solution[row][col] <= 0 || viewModel.solution[row][col + 1] <= 0 {
            return false
        }
        if let regions = viewModel.regions {
            return regions[row][col] != regions[row][col + 1]
        }
        if !viewModel.subGrids.isEmpty {
            return isSubGridBoxBoundaryVertical(row: row, col: col)
        }
        return (col + 1) % viewModel.boxCols == 0
    }

    private func isThickHorizontalBorder(row: Int, col: Int) -> Bool {
        let gridSize = viewModel.gridSize
        guard row + 1 < gridSize else { return false }
        if viewModel.solution[row][col] <= 0 || viewModel.solution[row + 1][col] <= 0 {
            return false
        }
        if let regions = viewModel.regions {
            return regions[row][col] != regions[row + 1][col]
        }
        if !viewModel.subGrids.isEmpty {
            return isSubGridBoxBoundaryHorizontal(row: row, col: col)
        }
        return (row + 1) % viewModel.boxRows == 0
    }

    // Check if the vertical border between (row,col) and (row,col+1) is a sub-grid box boundary
    private func isSubGridBoxBoundaryVertical(row: Int, col: Int) -> Bool {
        for sg in viewModel.subGrids {
            guard sg.contains(row: row, col: col) && sg.contains(row: row, col: col + 1) else { continue }
            let localCol = col - sg.startCol
            if (localCol + 1) % sg.boxCols == 0 {
                return true
            }
        }
        return false
    }

    // Check if the horizontal border between (row,col) and (row+1,col) is a sub-grid box boundary
    private func isSubGridBoxBoundaryHorizontal(row: Int, col: Int) -> Bool {
        for sg in viewModel.subGrids {
            guard sg.contains(row: row, col: col) && sg.contains(row: row + 1, col: col) else { continue }
            let localRow = row - sg.startRow
            if (localRow + 1) % sg.boxRows == 0 {
                return true
            }
        }
        return false
    }

    private func computeVerticalBorderWidths() -> [CGFloat] {
        let gridSize = viewModel.gridSize
        let colCount = viewModel.solution[0].count
        guard colCount > 1 else { return [] }
        var widths = [CGFloat](repeating: 0.5, count: colCount - 1)

        if let regions = viewModel.regions {
            for col in 0..<(colCount - 1) {
                for row in 0..<gridSize {
                    if regions[row][col] != regions[row][col + 1] {
                        widths[col] = 2
                        break
                    }
                }
            }
        } else if !viewModel.subGrids.isEmpty {
            for col in 0..<(colCount - 1) {
                for row in 0..<gridSize {
                    if viewModel.solution[row][col] > 0 && viewModel.solution[row][col + 1] > 0 {
                        if isSubGridBoxBoundaryVertical(row: row, col: col) {
                            widths[col] = 2
                            break
                        }
                    }
                }
            }
        } else {
            for col in 0..<(colCount - 1) {
                widths[col] = (col + 1) % viewModel.boxCols == 0 ? 2 : 0.5
            }
        }

        return widths
    }

    private func computeHorizontalBorderHeights() -> [CGFloat] {
        let gridSize = viewModel.gridSize
        let colCount = viewModel.solution[0].count
        guard gridSize > 1 else { return [] }
        var heights = [CGFloat](repeating: 0.5, count: gridSize - 1)

        if let regions = viewModel.regions {
            for row in 0..<(gridSize - 1) {
                for col in 0..<colCount {
                    if regions[row][col] != regions[row + 1][col] {
                        heights[row] = 2
                        break
                    }
                }
            }
        } else if !viewModel.subGrids.isEmpty {
            for row in 0..<(gridSize - 1) {
                for col in 0..<colCount {
                    if viewModel.solution[row][col] > 0 && viewModel.solution[row + 1][col] > 0 {
                        if isSubGridBoxBoundaryHorizontal(row: row, col: col) {
                            heights[row] = 2
                            break
                        }
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
        let colCount = CGFloat(viewModel.solution[0].count)
        let totalBorderWidth = vBorderWidths.reduce(CGFloat(0), +)
        let outerBorderWidth: CGFloat = viewModel.gameType == .flower || viewModel.gameType == .miniSamurai ? 0 : 4
        let available = screenWidth - padding * 2 - totalBorderWidth - outerBorderWidth
        return floor(available / colCount)
    }

    // MARK: - Killer Cage Helpers

    private func computeCageSum(row: Int, col: Int) -> Int? {
        guard let cageLookup = viewModel.cageLookup,
              let cages = viewModel.cages else { return nil }
        let cageIndex = cageLookup[row][col]
        guard cageIndex >= 0 else { return nil }
        let cage = cages[cageIndex]
        guard cage.cells.count > 1 && cage.cells.count <= viewModel.maxCageSize else { return nil }
        // Show sum only on the first cell of the cage
        if cage.cells[0][0] == row && cage.cells[0][1] == col {
            return cage.sum
        }
        return nil
    }

    private func computeCageBorders(row: Int, col: Int) -> (top: Bool, right: Bool, bottom: Bool, left: Bool) {
        guard let cageLookup = viewModel.cageLookup,
              let cages = viewModel.cages else {
            return (false, false, false, false)
        }
        let myCage = cageLookup[row][col]
        guard myCage >= 0 else { return (false, false, false, false) }
        guard cages[myCage].cells.count > 1 && cages[myCage].cells.count <= viewModel.maxCageSize else { return (false, false, false, false) }

        let gridRows = viewModel.gridSize
        let gridCols = viewModel.solution[0].count

        let top = row == 0 || cageLookup[row - 1][col] != myCage
        let bottom = row == gridRows - 1 || cageLookup[row + 1][col] != myCage
        let left = col == 0 || cageLookup[row][col - 1] != myCage
        let right = col == gridCols - 1 || cageLookup[row][col + 1] != myCage

        return (top, right, bottom, left)
    }

    // MARK: - Sub-Grid Overlay

    private func subGridOverlay(cellSize: CGFloat, vBorderWidths: [CGFloat], hBorderHeights: [CGFloat]) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear
            ForEach(0..<viewModel.subGrids.count, id: \.self) { i in
                let sg = viewModel.subGrids[i]
                if sg.isCenter || viewModel.gameType != .flower {
                    let x = gridXOffset(col: sg.startCol, cellSize: cellSize, vBorderWidths: vBorderWidths)
                    let y = gridYOffset(row: sg.startRow, cellSize: cellSize, hBorderHeights: hBorderHeights)
                    let endX = gridXOffset(col: sg.startCol + sg.size, cellSize: cellSize, vBorderWidths: vBorderWidths)
                    let endY = gridYOffset(row: sg.startRow + sg.size, cellSize: cellSize, hBorderHeights: hBorderHeights)

                    Rectangle()
                        .stroke(sg.isCenter ? Color.red : Color.primary, lineWidth: 2)
                        .frame(width: endX - x, height: endY - y)
                        .offset(x: x, y: y)
                }
            }
        }
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
