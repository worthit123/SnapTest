import SwiftUI

struct ContentView: View {
    @State private var gameState = GameState.ready
    @State private var reactionTime: Int?
    @State private var bestTime: Int?
    @State private var startTime: Date?
    @State private var timer: DispatchWorkItem?

    enum GameState {
        case ready
        case waiting
        case go
        case result
        case tooSoon
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Image(systemName: "bolt.fill")
                    .font(.system(size: 55))
                    .foregroundStyle(.white)

                Text("SnapTest")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.white)

                Text(statusText)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                if let reactionTime = reactionTime,
                   gameState == .result {
                    VStack(spacing: 8) {
                        Text("\(reactionTime) ms")
                            .font(.system(size: 52, weight: .bold))
                            .foregroundStyle(.white)

                        Text(reactionRating(reactionTime))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                if let bestTime = bestTime {
                    Text("Best: \(bestTime) ms")
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Button(action: handleTap) {
                    Text(buttonText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, 30)
                .disabled(gameState == .waiting)

                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
        .onDisappear {
            timer?.cancel()
        }
    }

    private var backgroundColor: Color {
        switch gameState {
        case .ready, .result:
            return Color.black
        case .waiting:
            return Color.red
        case .go:
            return Color.green
        case .tooSoon:
            return Color.orange
        }
    }

    private var statusText: String {
        switch gameState {
        case .ready:
            return "How fast can you react?"
        case .waiting:
            return "WAIT..."
        case .go:
            return "TAP!"
        case .result:
            return "Your reaction time"
        case .tooSoon:
            return "Too soon!"
        }
    }

    private var buttonText: String {
        switch gameState {
        case .ready, .result, .tooSoon:
            return "TAP TO START"
        case .waiting:
            return "WAIT..."
        case .go:
            return "TAP!"
        }
    }

    private func handleTap() {
        switch gameState {
        case .ready, .result, .tooSoon:
            startGame()

        case .waiting:
            return

        case .go:
            finishGame()
        }
    }

    private func startGame() {
        timer?.cancel()

        reactionTime = nil
        gameState = .waiting

        let delay = Double.random(in: 1.5...4.0)

        let work = DispatchWorkItem {
            DispatchQueue.main.async {
                if !self.timer!.isCancelled {
                    self.startTime = Date()
                    self.gameState = .go
                }
            }
        }

        timer = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func finishGame() {
        guard let startTime = startTime else { return }

        let milliseconds = Int(Date().timeIntervalSince(startTime) * 1000)

        reactionTime = milliseconds

        if bestTime == nil || milliseconds < bestTime! {
            bestTime = milliseconds
        }

        gameState = .result
    }

    private func reactionRating(_ time: Int) -> String {
        switch time {
        case ..<150:
            return "🚀 INSANE!"
        case 150..<200:
            return "🔥 EXCELLENT!"
        case 200..<250:
            return "😎 GREAT!"
        case 250..<300:
            return "👍 GOOD!"
        case 300..<400:
            return "🙂 AVERAGE"
        default:
            return "🐌 KEEP TRYING!"
        }
    }
}
