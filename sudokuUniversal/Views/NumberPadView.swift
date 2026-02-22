import SwiftUI

struct NumberPadView: View {
    @Bindable var viewModel: SudokuGameViewModel

    var body: some View {
        let gridSize = viewModel.gridSize

        if gridSize <= 9 {
            // Single row for 9x9
            HStack(spacing: 8) {
                ForEach(1...gridSize, id: \.self) { number in
                    numberButton(number)
                }
            }
            .padding(.horizontal)
        } else {
            // Two rows for 16x16
            let half = gridSize / 2
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(1...half, id: \.self) { number in
                        numberButton(number)
                    }
                }
                HStack(spacing: 6) {
                    ForEach((half + 1)...gridSize, id: \.self) { number in
                        numberButton(number)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func numberButton(_ number: Int) -> some View {
        let isDisabled = viewModel.isNumberFullyPlaced(number)

        Button {
            viewModel.inputNumber(number)
        } label: {
            Text("\(number)")
                .font(viewModel.gridSize <= 9
                      ? .title2.bold()
                      : .callout.bold())
                .frame(maxWidth: .infinity)
                .frame(height: viewModel.gridSize <= 9 ? 50 : 42)
                .background(isDisabled ? Color.gray.opacity(0.15) : Color.blue.opacity(0.12))
                .foregroundStyle(isDisabled ? .gray : .blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(isDisabled || viewModel.gameStatus != .playing)
    }
}
