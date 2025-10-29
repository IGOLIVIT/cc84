//
//  PuzzleGameView.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI

struct PuzzleGameView: View {
    let user: User
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: PuzzleGameViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showPauseMenu = false
    
    init(user: User, appState: AppState) {
        self.user = user
        self.appState = appState
        self._viewModel = StateObject(wrappedValue: PuzzleGameViewModel(user: user))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            if viewModel.showCompletionAlert {
                // Victory Screen
                VictoryView(
                    score: viewModel.score,
                    streak: viewModel.user.currentStreak,
                    bonus: viewModel.streakBonus,
                    level: viewModel.currentLevel,
                    onNextLevel: {
                        appState.updateUser(viewModel.user)
                        viewModel.showCompletionAlert = false
                        viewModel.startNextLevel()
                    },
                    onExit: {
                        appState.updateUser(viewModel.user)
                        viewModel.showCompletionAlert = false
                        viewModel.resetGame()
                    }
                )
                .zIndex(100)
            } else if viewModel.showFailureAlert {
                // Failure Screen
                FailureView(
                    onRetry: {
                        appState.updateUser(viewModel.user)
                        viewModel.showFailureAlert = false
                        viewModel.startNewGame(difficulty: viewModel.user.settings.difficultyPreference)
                    },
                    onExit: {
                        appState.updateUser(viewModel.user)
                        viewModel.showFailureAlert = false
                        viewModel.resetGame()
                    }
                )
                .zIndex(100)
            } else if viewModel.isGameActive {
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        // Pause Button
                        Button(action: {
                            viewModel.pauseGame()
                            showPauseMenu = true
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#06dbab"))
                        }
                        
                        Spacer()
                        
                        // Level
                        VStack(spacing: 4) {
                            Text("LEVEL")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.currentLevel)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Timer
                        VStack(spacing: 4) {
                            Text("TIME")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text(timeString(from: viewModel.timeRemaining))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(viewModel.timeRemaining < 10 ? Color(hex: "#ff2300") : .white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    
                    // Score View
                    ScoreView(
                        score: viewModel.score,
                        streak: viewModel.user.currentStreak
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // Game Instructions
                    VStack(spacing: 8) {
                        Text("🎯 Match the ghost shapes!")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#06dbab"))
                        Text("Tap to rotate • Drag to move")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    
                    // Puzzle Board
                    if let puzzle = viewModel.currentPuzzle {
                        PuzzleBoardView(
                            puzzle: puzzle,
                            selectedPieceId: $viewModel.selectedPieceId,
                            onMovePiece: { id, position in
                                viewModel.movePiece(id: id, to: position)
                            },
                            onRotatePiece: { id in
                                viewModel.rotatePiece(id: id)
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 450) // Фиксированная высота игрового поля
                        .clipped() // Обрезаем всё что выходит за границы
                    }
                    
                    Spacer()
                        .frame(height: 100) // Пространство для таббара
                }
            } else {
                // Start Screen
                VStack(spacing: 30) {
                    Text("🧠")
                        .font(.system(size: 100))
                    
                    Text("Ready to challenge your mind?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(spacing: 15) {
                        ForEach(Puzzle.Difficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                viewModel.startNewGame(difficulty: difficulty)
                            }) {
                                HStack {
                                    Text(difficulty.rawValue.capitalized)
                                        .font(.headline)
                                    Spacer()
                                    Text("\(difficulty.pieceCount) pieces")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(difficultyColor(difficulty))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .sheet(isPresented: $showPauseMenu) {
            PauseMenuView(
                isPresented: $showPauseMenu,
                onResume: {
                    viewModel.resumeGame()
                    showPauseMenu = false
                },
                onQuit: {
                    viewModel.resetGame()
                    showPauseMenu = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func timeString(from seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
    private func difficultyColor(_ difficulty: Puzzle.Difficulty) -> Color {
        switch difficulty {
        case .easy:
            return Color(hex: "#06dbab")
        case .medium:
            return Color(hex: "#FFD700")
        case .hard:
            return Color(hex: "#ff2300")
        case .expert:
            return Color(hex: "#9B59B6")
        }
    }
}

// MARK: - Pause Menu View
struct PauseMenuView: View {
    @Binding var isPresented: Bool
    let onResume: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Game Paused")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Button(action: onResume) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#06dbab"))
                        .cornerRadius(12)
                    }
                    
                    Button(action: onQuit) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Quit to Menu")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#ff2300"))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

