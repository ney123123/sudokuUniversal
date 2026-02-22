import SwiftUI

struct GameSelectionView: View {
    @Binding var navigationPath: NavigationPath

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(SudokuGameType.allCases.enumerated()), id: \.element.id) { index, gameType in
                    GameTypeCard(gameType: gameType) {
                        navigationPath.append(AppRoute.game(gameType))
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05),
                        value: appeared
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Choose a Game")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            appeared = true
        }
    }

    @State private var appeared = false
}

#Preview {
    NavigationStack {
        GameSelectionView(navigationPath: .constant(NavigationPath()))
    }
}
