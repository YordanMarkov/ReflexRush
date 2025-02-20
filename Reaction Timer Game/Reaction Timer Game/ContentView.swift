//
//  ContentView.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 13.02.25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var startTime: Date?
    @State private var reactionTime: Double?
    @State private var gameMessage: String = "Shake your device to start!"
    @State private var isGameActive: Bool = false
    @State private var leaderboard: [Double] = [] // to store the times (leaderboard)

    private var backgroundColor: Color {
        gameMessage == "TAP!" ? .red : .white // just to become red on "TAP!"
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
                .onTapGesture {
                    if isGameActive, let start = startTime {
                        let elapsedTime = Date().timeIntervalSince(start)
                        reactionTime = elapsedTime
                        gameMessage = "You tapped!"
                        isGameActive = false
                        updateLeaderboard(time: elapsedTime) // to save the result and sort it out in the leaderboard
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                    startGame()
                }

            VStack {
                Text(gameMessage)
                    .font(.title)
                    .padding()

                if let time = reactionTime {
                    HStack {
                        Text("Reaction Time: ")
                            .foregroundColor(.black)
                        
                        Text("\(String(format: "%.3f", time)) seconds")
                            .foregroundColor(.blue)
                    }
                    VStack {
                        Text("🏆 Leaderboard 🏆")
                            .font(.headline)
                            .padding(.top)

                        ForEach(leaderboard.prefix(10), id: \.self) { time in
                            Text("\(String(format: "%.3f", time)) sec")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    Spacer()
                    Button(
                        action: {
                            startGame()
                        }) {
                            Text("Play again?")
                                .frame(width: 150, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)

                        }
                }
            }
        }
    }

    func startGame() {
        reactionTime = nil
        isGameActive = false
        gameMessage = "Get Ready!"

        DispatchQueue.global().async {
            for i in 1...3 {
                DispatchQueue.main.async {
                    gameMessage = "\(4-(i))"
                }
                sleep(1)
            }

            DispatchQueue.main.async {
                gameMessage = "Wait for it..."
            }

            let randomTimeInterval: Double = .random(in: 0.5...2.0)
            sleep(UInt32(randomTimeInterval))

            DispatchQueue.main.async {
                gameMessage = "TAP!"
                startTime = Date()
                isGameActive = true
            }
        }
    }
    
    func updateLeaderboard(time: Double) {
        leaderboard.append(time)
        leaderboard.sort() // sort them out - fast -> slow
        if leaderboard.count > 10 {
            leaderboard.removeLast() // just to keep top 10, no more
        }
    }
}


// Shake Gesture Detection
extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
