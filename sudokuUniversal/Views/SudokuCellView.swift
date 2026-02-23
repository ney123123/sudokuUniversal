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
    var isNonExistent: Bool = false
    var cageSum: Int? = nil
    var cageBorders: (top: Bool, right: Bool, bottom: Bool, left: Bool) = (false, false, false, false)
    var isCageHighlighted: Bool = false

    var body: some View {
        if isNonExistent {
            Color.clear
                .frame(width: cellSize, height: cellSize)
                .contentShape(Rectangle().size(.zero))
        } else {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(backgroundColor)

                if value != 0 {
                    Text(displayText)
                        .font(numberFont)
                        .fontWeight(isPrefilled ? .bold : .regular)
                        .foregroundColor(isPrefilled ? .primary : .blue)
                        .frame(width: cellSize, height: cellSize)
                }

                // Cage sum label (top-left corner)
                if let cageSum {
                    Text("\(cageSum)")
                        .font(.system(size: cellSize * 0.25))
                        .foregroundColor(isCageHighlighted ? Color(red: 0, green: 0, blue: 0.7) : .secondary)
                        .padding(3)
                }

                // Cage dashed borders
                cageBorderOverlay
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

    @ViewBuilder
    private var cageBorderOverlay: some View {
        if cageBorders.top || cageBorders.right || cageBorders.bottom || cageBorders.left {
            Canvas { context, size in
                let dash: [CGFloat] = isCageHighlighted ? [] : [3, 2]
                let lineWidth: CGFloat = isCageHighlighted ? 4 : 1
                var path = Path()
                if cageBorders.top {
                    path.move(to: CGPoint(x: 0, y: 0.5))
                    path.addLine(to: CGPoint(x: size.width, y: 0.5))
                }
                if cageBorders.bottom {
                    path.move(to: CGPoint(x: 0, y: size.height - 0.5))
                    path.addLine(to: CGPoint(x: size.width, y: size.height - 0.5))
                }
                if cageBorders.left {
                    path.move(to: CGPoint(x: 0.5, y: 0))
                    path.addLine(to: CGPoint(x: 0.5, y: size.height))
                }
                if cageBorders.right {
                    path.move(to: CGPoint(x: size.width - 0.5, y: 0))
                    path.addLine(to: CGPoint(x: size.width - 0.5, y: size.height))
                }
                context.stroke(path, with: .color(isCageHighlighted ? Color(red: 0, green: 0, blue: 0.7) : .primary.opacity(0.6)), style: StrokeStyle(lineWidth: lineWidth, dash: dash))
            }
            .allowsHitTesting(false)
        }
    }

    @State private var shakeOffset: CGFloat = 0
}
