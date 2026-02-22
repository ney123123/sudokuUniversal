import SwiftUI

struct SudokuCellView: View {
    let row: Int
    let col: Int
    let value: Int
    let isPrefilled: Bool
    let isSelected: Bool
    let isSameRowOrCol: Bool
    let isSameBox: Bool
    let isSameNumber: Bool
    let isWrong: Bool
    let cellSize: CGFloat
    let gridSize: Int
    let regionColor: Color?

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundColor)

            if value != 0 {
                Text(displayText)
                    .font(numberFont)
                    .fontWeight(isPrefilled ? .bold : .regular)
                    .foregroundColor(isPrefilled ? .primary : .blue)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .overlay {
            if isSelected {
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
            }
        }
        .contentShape(Rectangle())
        .offset(x: isWrong ? shakeOffset : 0)
    }

    private var displayText: String {
        "\(value)"
    }

    private var numberFont: Font {
        if gridSize == 16 {
            return .system(size: cellSize * 0.45, weight: isPrefilled ? .bold : .regular, design: .rounded)
        }
        return .system(size: cellSize * 0.5, weight: isPrefilled ? .bold : .regular, design: .rounded)
    }

    private var backgroundColor: Color {
        if isWrong {
            return .red.opacity(0.5)
        }
        if isSameNumber && value != 0 {
            return .blue.opacity(0.15)
        }
        if isSameRowOrCol || isSameBox {
            return .blue.opacity(0.08)
        }
        if let regionColor {
            return regionColor
        }
        if isPrefilled {
            return Color(.systemGray6)
        }
        return .clear
    }

    @State private var shakeOffset: CGFloat = 0
}
