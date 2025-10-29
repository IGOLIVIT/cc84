//
//  ScoreView.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI

struct ScoreView: View {
    let score: Int
    let streak: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 20) {
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color(hex: "#FFD700"))
                    Text("\(score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Streak
            if streak > 0 {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("STREAK")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    HStack(spacing: 5) {
                        Text("\(streak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(hex: "#ff2300"))
                            .scaleEffect(isAnimating ? 1.2 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                .onAppear {
                    isAnimating = true
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}


