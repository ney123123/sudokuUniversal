import SwiftUI

struct SudokuGameView: View {
    let gameType: SudokuGameType
    let difficulty: String
    @Binding var navigationPath: NavigationPath

    @State private var viewModel: SudokuGameViewModel?
    @State private var loadError = false

    var body: some View {
        Group {
            if let viewModel {
                gameContent(viewModel)
            } else if loadError {
                ContentUnavailableView(
                    "Puzzle Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Could not load a \(difficulty) puzzle.")
                )
            } else {
                ProgressView("Loading puzzle...")
            }
        }
        .navigationTitle(gameType.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel?.gameStatus == .playing)
        .toolbar {
            if viewModel?.gameStatus == .playing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel?.pauseTimer()
                        navigationPath.removeLast(navigationPath.count)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Quit")
                        }
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                loadPuzzle()
            } else {
                viewModel?.startTimer()
            }
        }
        .onDisappear {
            viewModel?.pauseTimer()
        }
    }

    @ViewBuilder
    private func gameContent(_ vm: SudokuGameViewModel) -> some View {
        ZStack {
            VStack(spacing: 0) {
                // Header: Lives + Timer
                headerBar(vm)
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                // Grid
                SudokuGridView(viewModel: vm)
                    .padding(.horizontal, 8)

                Spacer().frame(height: 20)

                // Number Pad
                NumberPadView(viewModel: vm)

                Spacer()
            }

            // Overlays
            if vm.gameStatus == .lost {
                Color.black.opacity(0.4).ignoresSafeArea()
                GameOverView(
                    time: vm.formattedTime,
                    onRetry: { loadPuzzle() },
                    onMenu: { navigationPath.removeLast(navigationPath.count) }
                )
                .transition(.scale.combined(with: .opacity))
            }

            if vm.gameStatus == .won {
                Color.black.opacity(0.4).ignoresSafeArea()
                GameWonView(
                    time: vm.formattedTime,
                    onNextPuzzle: { loadPuzzle() },
                    onMenu: { navigationPath.removeLast(navigationPath.count) }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.gameStatus == .lost)
        .animation(.easeInOut(duration: 0.3), value: vm.gameStatus == .won)
    }

    @ViewBuilder
    private func headerBar(_ vm: SudokuGameViewModel) -> some View {
        HStack {
            // Lives
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < vm.livesRemaining ? "heart.fill" : "heart")
                        .foregroundStyle(index < vm.livesRemaining ? .red : .gray)
                        .font(.title3)
                }
            }

            Spacer()

            // Difficulty label
            Text(difficulty)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            // Timer
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                Text(vm.formattedTime)
                    .font(.headline.monospacedDigit())
            }
        }
    }

    private func loadPuzzle() {
        guard let puzzle = PuzzleLoader.loadPuzzle(for: gameType, difficulty: difficulty) else {
            loadError = true
            return
        }
        let vm = SudokuGameViewModel(puzzle: puzzle, gameType: gameType, difficulty: difficulty)
        self.viewModel = vm
        self.loadError = false
        vm.startTimer()
    }
}
