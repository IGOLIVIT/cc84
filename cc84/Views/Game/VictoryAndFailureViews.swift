//
//  VictoryAndFailureViews.swift
//  CognifyQuest
//
//  Created by IGOR on 29/10/2025.
//

import SwiftUI

// MARK: - Victory View
struct VictoryView: View {
    let score: Int
    let streak: Int
    let bonus: Int
    let level: Int
    let onNextLevel: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Victory!")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Level \(level) Complete!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(spacing: 15) {
                    HStack {
                        Text("Score:")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("+\(score)")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#FFD700"))
                    }
                    
                    HStack {
                        Text("Streak:")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(streak) 🔥")
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#ff2300"))
                    }
                    
                    if bonus > 0 {
                        HStack {
                            Text("Bonus:")
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text("+\(bonus)")
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#06dbab"))
                        }
                    }
                }
                .font(.title3)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .padding(.horizontal, 40)
                
                VStack(spacing: 15) {
                    Button(action: onNextLevel) {
                        HStack {
                            Text("Next Level")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#06dbab"), Color(hex: "#ff2300")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    
                    Button(action: onExit) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - Failure View
struct FailureView: View {
    let onRetry: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("⏰")
                    .font(.system(size: 80))
                
                Text("Time's Up!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Don't give up!\nTry again")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 15) {
                    Button(action: onRetry) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#06dbab"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onExit) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

