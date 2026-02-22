import SwiftUI

struct HomeView: View {
    @Environment(GameStateManager.self) private var gameStateManager
    @Binding var navigationPath: NavigationPath
    @State private var showSettings = false
    @State private var showProfile = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App logo and title
            VStack(spacing: 12) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)

                Text("Sudoku Universal")
                    .font(.largeTitle.bold())

                Text("Choose your challenge")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 16) {
                if gameStateManager.hasUnfinishedGame {
                    Button {
                        if let route = gameStateManager.resumeRoute() {
                            navigationPath.append(route)
                        }
                    } label: {
                        Label("Resume Game", systemImage: "play.fill")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Button {
                    navigationPath.append(AppRoute.gameSelection)
                } label: {
                    Label("Start New Game", systemImage: "plus.circle.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSettings) {
            SettingsPlaceholderView()
        }
        .sheet(isPresented: $showProfile) {
            ProfilePlaceholderView()
        }
        .onAppear {
            gameStateManager.checkForUnfinishedGame()
        }
        .animation(.easeInOut, value: gameStateManager.hasUnfinishedGame)
    }
}

#Preview {
    NavigationStack {
        HomeView(navigationPath: .constant(NavigationPath()))
    }
    .environment(GameStateManager())
}
