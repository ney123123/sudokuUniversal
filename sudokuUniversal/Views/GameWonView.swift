import SwiftUI

struct GameWonView: View {
    let time: String
    let onNextPuzzle: () -> Void
    let onMenu: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Congratulations!")
                .font(.largeTitle.bold())

            Text("Completed in \(time)")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Button(action: onNextPuzzle) {
                    Label("Next Puzzle", systemImage: "arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onMenu) {
                    Text("Back to Menu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 20)
        .padding(32)
    }
}
