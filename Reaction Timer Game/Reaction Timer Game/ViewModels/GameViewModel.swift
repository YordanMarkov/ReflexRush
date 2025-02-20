//
//  GameViewModel.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 20.02.25.
//

import SwiftUI

class GameViewModel: ObservableObject {
    @Published var startTime: Date?
    @Published var reactionTime: Double?
    @Published var gameMessage: String = "Shake your device to start!"
    @Published var isGameActive: Bool = false
    @Published var leaderboard: [Double] = []

    var backgroundColor: Color {
        gameMessage == "TAP!" ? .red : .white
    }

    func startGame() {
        reactionTime = nil
        isGameActive = false
        gameMessage = "Get Ready!"

        DispatchQueue.global().async {
            for i in 1...3 {
                DispatchQueue.main.async {
                    self.gameMessage = "\(4-(i))"
                }
                sleep(1)
            }

            DispatchQueue.main.async {
                self.gameMessage = "Wait for it..."
            }

            let randomTimeInterval: Double = .random(in: 0.5...2.0)
            sleep(UInt32(randomTimeInterval))

            DispatchQueue.main.async {
                self.gameMessage = "TAP!"
                self.startTime = Date()
                self.isGameActive = true
            }
        }
    }

    func registerTap() {
        if isGameActive, let start = startTime {
            let elapsedTime = Date().timeIntervalSince(start)
            reactionTime = elapsedTime
            gameMessage = "You tapped!"
            isGameActive = false
            updateLeaderboard(time: elapsedTime)
        }
    }

    func updateLeaderboard(time: Double) {
        leaderboard.append(time)
        leaderboard.sort()
        if leaderboard.count > 10 {
            leaderboard.removeLast()
        }
    }
}
