//
//  DataSyncService.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import CloudKit
import Combine

class DataSyncService: ObservableObject {
    static let shared = DataSyncService()
    
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private var cancellables = Set<AnyCancellable>()
    
    // Record types
    private let userRecordType = "User"
    private let statisticsRecordType = "Statistics"
    
    init() {
        container = CKContainer.default()
        privateDatabase = container.privateCloudDatabase
    }
    
    // MARK: - User Data Sync
    func saveUser(_ user: User) async throws {
        isSyncing = true
        defer { isSyncing = false }
        
        let record = CKRecord(recordType: userRecordType)
        record["userId"] = user.id.uuidString as CKRecordValue
        record["username"] = user.username as CKRecordValue
        record["avatarEmoji"] = user.avatarEmoji as CKRecordValue
        record["totalScore"] = user.totalScore as CKRecordValue
        record["highScore"] = user.highScore as CKRecordValue
        record["levelsCompleted"] = user.levelsCompleted as CKRecordValue
        record["currentStreak"] = user.currentStreak as CKRecordValue
        record["longestStreak"] = user.longestStreak as CKRecordValue
        record["createdAt"] = user.createdAt as CKRecordValue
        
        if let lastPlayed = user.lastPlayedAt {
            record["lastPlayedAt"] = lastPlayed as CKRecordValue
        }
        
        // Encode statistics
        if let statisticsData = try? JSONEncoder().encode(user.statistics) {
            record["statistics"] = statisticsData as CKRecordValue
        }
        
        // Encode settings
        if let settingsData = try? JSONEncoder().encode(user.settings) {
            record["settings"] = settingsData as CKRecordValue
        }
        
        do {
            _ = try await privateDatabase.save(record)
            lastSyncDate = Date()
            syncError = nil
        } catch {
            syncError = error
            throw error
        }
    }
    
    func fetchUser(userId: UUID) async throws -> User? {
        isSyncing = true
        defer { isSyncing = false }
        
        let predicate = NSPredicate(format: "userId == %@", userId.uuidString)
        let query = CKQuery(recordType: userRecordType, predicate: predicate)
        
        do {
            let results = try await privateDatabase.records(matching: query)
            
            guard let record = results.matchResults.first?.1 else {
                return nil
            }
            
            let fetchedRecord = try record.get()
            
            guard let userIdString = fetchedRecord["userId"] as? String,
                  let fetchedUserId = UUID(uuidString: userIdString),
                  let username = fetchedRecord["username"] as? String,
                  let avatarEmoji = fetchedRecord["avatarEmoji"] as? String,
                  let totalScore = fetchedRecord["totalScore"] as? Int,
                  let highScore = fetchedRecord["highScore"] as? Int,
                  let levelsCompleted = fetchedRecord["levelsCompleted"] as? Int,
                  let currentStreak = fetchedRecord["currentStreak"] as? Int,
                  let longestStreak = fetchedRecord["longestStreak"] as? Int,
                  let createdAt = fetchedRecord["createdAt"] as? Date else {
                return nil
            }
            
            var user = User(username: username, avatarEmoji: avatarEmoji)
            user.totalScore = totalScore
            user.highScore = highScore
            user.levelsCompleted = levelsCompleted
            user.currentStreak = currentStreak
            user.longestStreak = longestStreak
            user.createdAt = createdAt
            user.lastPlayedAt = fetchedRecord["lastPlayedAt"] as? Date
            
            // Decode statistics
            if let statisticsData = fetchedRecord["statistics"] as? Data,
               let statistics = try? JSONDecoder().decode(GameStatistics.self, from: statisticsData) {
                user.statistics = statistics
            }
            
            // Decode settings
            if let settingsData = fetchedRecord["settings"] as? Data,
               let settings = try? JSONDecoder().decode(UserSettings.self, from: settingsData) {
                user.settings = settings
            }
            
            lastSyncDate = Date()
            syncError = nil
            
            return user
            
        } catch {
            syncError = error
            throw error
        }
    }
    
    // MARK: - CloudKit Availability Check
    func checkCloudKitAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
    
    // MARK: - Manual Sync
    func syncUserData(_ user: User) {
        Task {
            do {
                try await saveUser(user)
            } catch {
                print("Sync failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CloudKit Error Extension
extension CKError {
    var isRecoverable: Bool {
        switch code {
        case .networkFailure, .networkUnavailable, .serviceUnavailable, .requestRateLimited:
            return true
        default:
            return false
        }
    }
}


