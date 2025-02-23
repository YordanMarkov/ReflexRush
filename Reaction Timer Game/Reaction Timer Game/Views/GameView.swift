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
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
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
    
    func medal(for index: Int) -> String {
        switch index {
            case 0: return "🥇"
            case 1: return "🥈"
            case 2: return "🥉"
            default: return ""
        }
    }
    
    func isImportantMessage(_ message: String) -> Bool {
        return ["TAP!", "Wait...", "1", "2", "3"].contains(message)
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
                if viewModel.gameMessage == "" {
                    VStack {
                        Image("phone")
                            .rotationEffect(.degrees(rotationAngle))
                            .onAppear {
                                startShakeAnimation()
                            }
                            .padding(.top, 110)
                        
                        VStack {
                            Spacer()

                            VStack {
                                Text("Shake to")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)

                                Text("START")
                                    .font(.system(size: 70, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .background(Color(red: 0.537, green: 0.714, blue: 0.945))
                        }
                        .frame(maxHeight: .infinity)
                        .ignoresSafeArea()
                    }
                }

                if let time = viewModel.reactionTime {
                    VStack {
                        Text("Your reaction time is ")
                            .foregroundColor(Color(red: 0.537, green: 0.714, blue: 0.945))
                            .font(.title3)
                        
                        Text("\(String(format: "%.3f", time)) seconds")
                            .foregroundColor(.white)
                            .font(.title)
                            .bold()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 0.537, green: 0.714, blue: 0.945))
                            )
                    }
                    .padding(.top, 50)
                }
                
                if viewModel.gameMessage != "" {
                    Text(viewModel.gameMessage)
                        .font(isImportantMessage(viewModel.gameMessage) ? .system(size: 60, weight: .bold) : .title)
                        .padding()
                        .foregroundColor(isImportantMessage(viewModel.gameMessage) ? .white : .black)
                        .multilineTextAlignment(.center)
                }
                
                if viewModel.reactionTime != nil {
                    HStack(spacing: 40) {
                        Image("trophy")

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(viewModel.leaderboard.prefix(3).enumerated()), id: \.element) { index, time in
                                HStack {
                                    Text("\(medal(for: index))")
                                    Text("\(String(format: "%.3f", time)) sec")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    HStack(spacing: 10) {
                        Text("Share your\nresults")
                            .font(.system(size: 36))
                            .foregroundColor(Color(red: 0.537, green: 0.714, blue: 0.945))
                            .multilineTextAlignment(.trailing)
                        
                        Button(action: {
                            viewModel.shareLeaderboard()
                        }) {
                            Image("share")
                                .padding(10)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.537, green: 0.714, blue: 0.945))
                        )
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    VStack {
                        Spacer()

                        VStack {
                            Text("Play again?")
                                .font(.system(size: 60))
                                .foregroundColor(.white)

                            Text("SHAKE!")
                                .font(.system(size: 70, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .background(Color(red: 0.537, green: 0.714, blue: 0.945))
                    }
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()
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
