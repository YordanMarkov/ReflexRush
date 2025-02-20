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

    var body: some View {
        ZStack {
            viewModel.backgroundColor.ignoresSafeArea()
                .onTapGesture {
                    viewModel.registerTap()
                }
                .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
                    viewModel.startGame()
                }


            VStack {
                Text(viewModel.gameMessage)
                    .font(.title)
                    .padding()

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
