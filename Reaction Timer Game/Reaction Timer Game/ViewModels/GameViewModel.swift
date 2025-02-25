//
//  GameViewModel.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 20.02.25.
//

import SwiftUI
import AVFoundation // For the sounds
import UIKit // For the vibrations


class GameViewModel: ObservableObject {
    @Published var startTime: Date?
    @Published var reactionTime: Double?
    @Published var gameMessage: String = ""
    @Published var isGameActive: Bool = false
    @Published var isStarted: Bool = false
    @Published var leaderboard: [Double] = []
    @Published var gameCancelled: Bool = false
    private let gameQueue = OperationQueue()
    @Published var isGameRunning: Bool = false
    
    var audioPlayer: AVAudioPlayer?

    var backgroundColor: Color {
        if gameMessage == "TAP!" {
            return Color(red: 0.0, green: 0.133, blue: 1.0)
        } else if ["1", "2", "3"].contains(gameMessage) {
            return Color(red: 0.537, green: 0.714, blue: 0.945)
        } else if gameMessage == "Wait..." {
            return Color(red: 0.816, green: 0.357, blue: 0.624)
        } else if gameMessage == "TOO EARLY!" {
            return .red
        } else {
            return Color(red: 0.537, green: 0.714, blue: 0.945, opacity: 0.22)
        }
    }


    func playSound(named soundName: String) {
        guard let soundData = NSDataAsset(name: soundName)?.data else {
            print("Error: Could not find sound \(soundName) in assets")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(data: soundData)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func vibrateNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func resetGameState() {
        gameQueue.cancelAllOperations()
        gameCancelled = true
        isGameRunning = false
        isStarted = false
        isGameActive = false
        gameMessage = ""
        startTime = nil
        reactionTime = nil

        gameQueue.waitUntilAllOperationsAreFinished()
    }


    func startGame() {
        if isGameRunning { return }
        resetGameState()

        DispatchQueue.global(qos: .userInitiated).async {
            self.gameQueue.waitUntilAllOperationsAreFinished()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.gameCancelled = false
                self.isStarted = true
                self.isGameRunning = true
                self.reactionTime = nil
                self.isGameActive = false

                let gameOperation = BlockOperation {
                    for i in 1...3 {
                        if self.gameCancelled { return }
                        DispatchQueue.main.async {
                            self.gameMessage = "\(4 - i)"
                        }
                        self.playSound(named: "countdown-beep")
                        self.vibrate(style: .soft)
                        sleep(1)
                    }

                    DispatchQueue.main.async {
                        if self.gameCancelled { return }
                        self.gameMessage = "Wait..."
                    }

                    let randomTimeInterval: Double = .random(in: 2.0...5.0)

                    let startTime = Date()
                    while Date().timeIntervalSince(startTime) < randomTimeInterval {
                        if self.gameCancelled { return }
                        usleep(100_000)
                    }

                    DispatchQueue.main.async {
                        if self.gameCancelled { return }
                        self.gameMessage = "TAP!"
                        self.vibrate(style: .heavy)
                        self.startTime = Date()
                        self.isGameActive = true
                        self.isGameRunning = false
                    }
                }

                self.gameQueue.addOperation(gameOperation)
            }
        }
    }


    
    func registerTap() {
        if gameMessage == "Wait..." {
            resetGameState()
            gameMessage = "TOO EARLY!"
            playSound(named: "fail")
            vibrateNotification(type: .error)

            gameQueue.cancelAllOperations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startGame()
            }
            return
        }

        if isGameActive, let start = startTime {
            self.playSound(named: "tap-sound")
            self.vibrate(style: .light)
            let elapsedTime = Date().timeIntervalSince(start)
            reactionTime = elapsedTime
            gameMessage = reactionMessage(for: elapsedTime)
            isGameActive = false
            isStarted = false
            isGameRunning = false
            updateLeaderboard(time: elapsedTime)
        }
    }


    // Adding additional messages at the end so it makes the game more fun! (My opinion)
    func reactionMessage(for time: Double) -> String {
        switch time {
        case ..<0.2:
            return "🏎 Insane! You react like an F1 driver!"
        case 0.2..<0.25:
            return "🐱 Lightning fast! You react like a cat!"
        case 0.25..<0.3:
            return "🐇 Quick as a rabbit!"
        case 0.3..<0.35:
            return "🦅 Sharp as an eagle!"
        case 0.35..<0.4:
            return "🏃 Great reflexes! Like an athlete!"
        case 0.4..<0.45:
            return "🐶 Nice! You react like a trained dog!"
        case 0.45..<0.5:
            return "🦊 Clever! Fox-like reflexes!"
        case 0.5..<0.7:
            return "👨‍💻 Average human reaction speed!"
        case 0.7..<0.8:
            return "🐘 A bit slow... like an elephant!"
        default:
            return "🐢 Too slow! You react like a turtle!"
        }
    }


    func updateLeaderboard(time: Double) {
        leaderboard.append(time)
        leaderboard.sort()
        if leaderboard.count > 3 {
            leaderboard.removeLast()
        }
    }
    
    func shareLeaderboard() {
        let leaderboardText = leaderboard.prefix(10)
            .enumerated()
            .map { "\($0 + 1). \(String(format: "%.3f", $1)) sec" }
            .joined(separator: "\n")

        if let bestTime = leaderboard.min() {
            let message = """
            🚀 Hey, can you beat my reaction time? I just scored \(String(format: "%.3f", bestTime)) seconds!
            
            🏆 Leaderboard 🏆
            \(leaderboardText)
            
            Think you're faster? Try it now on Reflex Rush! ⚡️
            """

            let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true, completion: nil)
            }
        }
    }
}
