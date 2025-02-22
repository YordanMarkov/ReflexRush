//
//  GameView.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 20.02.25.
//

import SwiftUI
import UIKit

struct GameView: View {
    @ObservedObject private var viewModel = GameViewModel()
    
    @State private var rotationAngle: Double = 0
    @State private var isShaking = false

    func startShakeAnimation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in // Longer natural pause
            if !isShaking {
                isShaking = true
                
                withAnimation(Animation.easeInOut(duration: 0.3).repeatCount(5, autoreverses: true)) {
                    rotationAngle = -15 // Start left
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(Animation.easeInOut(duration: 0.3).repeatCount(5, autoreverses: true)) {
                        rotationAngle = 15
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(Animation.easeOut(duration: 0.6)) {
                        rotationAngle = 0
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isShaking = false
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()
                .onTapGesture {
                    viewModel.registerTap()
                }
                .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                    if !viewModel.isStarted {
                        viewModel.startGame()
                    }
                }


            VStack {
                if viewModel.gameMessage == "Shake your device to start!" {
                    Image("phone")
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            startShakeAnimation()
                        }
                }
                Text(viewModel.gameMessage)
                    .font(viewModel.gameMessage == "TAP!" ? .system(size: 60, weight: .bold) : .title)
                    .padding()
                    .foregroundColor(viewModel.gameMessage == "TAP!" ? .white : .black)

                if let time = viewModel.reactionTime {
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

                        ForEach(viewModel.leaderboard.prefix(10), id: \.self) { time in
                            Text("\(String(format: "%.3f", time)) sec")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    Spacer()
                    Button(
                        action: {
                            viewModel.startGame()
                        }) {
                            Text("Play again?")
                                .frame(width: 150, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)

                        }
                    Button(action: {
                        viewModel.shareLeaderboard()
                    }) {
                        Text("Share Score")
                            .frame(width: 150, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }

                }
            }
        }
    }
}

// Preview
struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
