//
//  User.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var username: String
    var avatarEmoji: String
    var totalScore: Int
    var highScore: Int
    var levelsCompleted: Int
    var currentStreak: Int
    var longestStreak: Int
    var statistics: GameStatistics
    var settings: UserSettings
    var createdAt: Date
    var lastPlayedAt: Date?
    
    init(username: String = "Player", avatarEmoji: String = "🧠") {
        self.id = UUID()
        self.username = username
        self.avatarEmoji = avatarEmoji
        self.totalScore = 0
        self.highScore = 0
        self.levelsCompleted = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.statistics = GameStatistics()
        self.settings = UserSettings()
        self.createdAt = Date()
        self.lastPlayedAt = nil
    }
    
    mutating func updateScore(points: Int) {
        totalScore += points
        if points > highScore {
            highScore = points
        }
    }
    
    mutating func completeLevel() {
        levelsCompleted += 1
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        lastPlayedAt = Date()
        statistics.gamesPlayed += 1
        statistics.gamesWon += 1
    }
    
    mutating func failLevel() {
        currentStreak = 0
        lastPlayedAt = Date()
        statistics.gamesPlayed += 1
    }
    
    mutating func reset() {
        totalScore = 0
        highScore = 0
        levelsCompleted = 0
        currentStreak = 0
        longestStreak = 0
        statistics = GameStatistics()
        lastPlayedAt = nil
    }
}

struct GameStatistics: Codable, Equatable {
    var gamesPlayed: Int
    var gamesWon: Int
    var totalTimePlayed: TimeInterval
    var averageCompletionTime: TimeInterval
    var perfectGames: Int // Completed without mistakes
    
    init() {
        self.gamesPlayed = 0
        self.gamesWon = 0
        self.totalTimePlayed = 0
        self.averageCompletionTime = 0
        self.perfectGames = 0
    }
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
}

struct UserSettings: Codable, Equatable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticFeedbackEnabled: Bool
    var difficultyPreference: Puzzle.Difficulty
    var showHints: Bool
    var colorBlindMode: Bool
    
    init() {
        self.soundEnabled = true
        self.musicEnabled = true
        self.hapticFeedbackEnabled = true
        self.difficultyPreference = .easy
        self.showHints = true
        self.colorBlindMode = false
    }
}

// MARK: - Avatar Options
enum AvatarEmoji: String, CaseIterable {
    case brain = "🧠"
    case rocket = "🚀"
    case star = "⭐️"
    case fire = "🔥"
    case trophy = "🏆"
    case gem = "💎"
    case crown = "👑"
    case puzzle = "🧩"
    case target = "🎯"
    case bulb = "💡"
    case wizard = "🧙‍♂️"
    case ninja = "🥷"
    case robot = "🤖"
    case alien = "👽"
    case unicorn = "🦄"
    
    var emoji: String {
        self.rawValue
    }
}

