import SwiftUI

struct DifficultySelectionView: View {
    let gameType: SudokuGameType
    @Binding var navigationPath: NavigationPath

    @State private var difficulties: [String] = []
    @State private var appeared = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(difficulties.enumerated()), id: \.element) { index, difficulty in
                    Button {
                        navigationPath.append(AppRoute.game(gameType, difficulty))
                    } label: {
                        HStack {
                            Text(difficulty)
                                .font(.title3.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(gameType.themeColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05),
                        value: appeared
                    )
                }
            }
            .padding()
        }
        .navigationTitle(gameType.displayName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if difficulties.isEmpty {
                difficulties = PuzzleLoader.availableDifficulties(for: gameType)
            }
            appeared = true
        }
    }
}
