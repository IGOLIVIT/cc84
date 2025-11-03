//
//  SettingsView.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI

struct SettingsView: View {
    let user: User
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: SettingsViewModel
    @State private var showAccountManagement = false
    
    init(user: User, appState: AppState) {
        self.user = user
        self.appState = appState
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(user: user))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 50)
                    
                    // Profile Card
                    Button(action: {
                        showAccountManagement = true
                    }) {
                        HStack(spacing: 15) {
                            Text(viewModel.user.avatarEmoji)
                                .font(.system(size: 50))
                                .frame(width: 70, height: 70)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(35)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(viewModel.user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Tap to edit profile")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    
                    // Game Settings
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Game Settings")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#06dbab"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            // Difficulty Preference
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Difficulty")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Puzzle.Difficulty.allCases, id: \.self) { difficulty in
                                            Button(action: {
                                                viewModel.updateDifficulty(difficulty)
                                            }) {
                                                Text(difficulty.rawValue.capitalized)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                    .frame(minWidth: 80)
                                                    .padding(.horizontal, 20)
                                                    .padding(.vertical, 10)
                                                    .background(
                                                        viewModel.user.settings.difficultyPreference == difficulty ?
                                                        Color(hex: "#ff2300") : Color.white.opacity(0.1)
                                                    )
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 15)
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                    }
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Your Progress")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#06dbab"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Total Score")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(viewModel.user.totalScore)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Text("Levels Completed")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(viewModel.user.levelsCompleted)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Text("Current Streak")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(viewModel.user.currentStreak) 🔥")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Text("Games Won")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(viewModel.user.statistics.gamesWon) / \(viewModel.user.statistics.gamesPlayed)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                    }
                    
                    // Account Management
                    Button(action: {
                        viewModel.showResetConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Reset App Data")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#ff2300"))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $showAccountManagement) {
            AccountManagementView(viewModel: viewModel)
        }
        .alert(isPresented: $viewModel.showResetConfirmation) {
            Alert(
                title: Text("Reset App Data"),
                message: Text("This will delete all your progress, scores, and settings. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetApp()
                    appState.updateUser(viewModel.user)
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: viewModel.user) { newUser in
            appState.updateUser(newUser)
        }
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#06dbab"))
                .frame(width: 25)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "#06dbab"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

