//
//  SettingsViewModel.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var user: User
    @Published var showResetConfirmation: Bool = false
    @Published var showProfileEditor: Bool = false
    
    init(user: User) {
        self.user = user
    }
    
    func toggleSound() {
        user.settings.soundEnabled.toggle()
    }
    
    func toggleMusic() {
        user.settings.musicEnabled.toggle()
    }
    
    func toggleHaptics() {
        user.settings.hapticFeedbackEnabled.toggle()
    }
    
    func toggleHints() {
        user.settings.showHints.toggle()
    }
    
    func toggleColorBlindMode() {
        user.settings.colorBlindMode.toggle()
    }
    
    func updateDifficulty(_ difficulty: Puzzle.Difficulty) {
        user.settings.difficultyPreference = difficulty
    }
    
    func updateUsername(_ newUsername: String) {
        user.username = newUsername.isEmpty ? "Player" : newUsername
    }
    
    func updateAvatar(_ emoji: String) {
        user.avatarEmoji = emoji
    }
    
    func resetApp() {
        user.reset()
        showResetConfirmation = false
    }
    
    func formatPlayTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getStatisticsData() -> [(label: String, value: String)] {
        return [
            ("Games Played", "\(user.statistics.gamesPlayed)"),
            ("Games Won", "\(user.statistics.gamesWon)"),
            ("Win Rate", String(format: "%.1f%%", user.statistics.winRate)),
            ("Perfect Games", "\(user.statistics.perfectGames)"),
            ("Total Score", "\(user.totalScore)"),
            ("High Score", "\(user.highScore)"),
            ("Levels Completed", "\(user.levelsCompleted)"),
            ("Current Streak", "\(user.currentStreak)"),
            ("Longest Streak", "\(user.longestStreak)")
        ]
    }
}

