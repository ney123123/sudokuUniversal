import SwiftUI

struct NumberPadView: View {
    @Bindable var viewModel: SudokuGameViewModel

    var body: some View {
        let maxDigit = viewModel.maxDigit

        if maxDigit <= 9 {
            // Single row for 9 or fewer digits
            HStack(spacing: 8) {
                ForEach(1...maxDigit, id: \.self) { number in
                    numberButton(number)
                }
            }
            .padding(.horizontal)
        } else {
            // Two rows for 16
            let half = maxDigit / 2
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(1...half, id: \.self) { number in
                        numberButton(number)
                    }
                }
                HStack(spacing: 6) {
                    ForEach((half + 1)...maxDigit, id: \.self) { number in
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
                .font(viewModel.maxDigit <= 9
                      ? .title2.bold()
                      : .callout.bold())
                .frame(maxWidth: .infinity)
                .frame(height: viewModel.maxDigit <= 9 ? 50 : 42)
                .background(isDisabled ? Color.gray.opacity(0.15) : Color.blue.opacity(0.12))
                .foregroundStyle(isDisabled ? .gray : .blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(isDisabled || viewModel.gameStatus != .playing)
    }
}
