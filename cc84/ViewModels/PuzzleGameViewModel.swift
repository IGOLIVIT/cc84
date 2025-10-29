//
//  PuzzleGameViewModel.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import SwiftUI
import Combine

class PuzzleGameViewModel: ObservableObject {
    @Published var currentPuzzle: Puzzle?
    @Published var timeRemaining: TimeInterval = 0
    @Published var score: Int = 0
    @Published var currentLevel: Int = 1
    @Published var isGameActive: Bool = false
    @Published var isGamePaused: Bool = false
    @Published var showCompletionAlert: Bool = false
    @Published var showFailureAlert: Bool = false
    @Published var selectedPieceId: UUID?
    @Published var streakBonus: Int = 0
    @Published var user: User
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(user: User) {
        self.user = user
    }
    
    func startNewGame(difficulty: Puzzle.Difficulty) {
        currentPuzzle = Puzzle(level: currentLevel, difficulty: difficulty)
        timeRemaining = currentPuzzle?.timeLimit ?? 60
        isGameActive = true
        isGamePaused = false
        startTimer()
    }
    
    func startNextLevel() {
        currentLevel += 1
        startNewGame(difficulty: user.settings.difficultyPreference)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.isGamePaused && self.isGameActive {
                self.timeRemaining -= 1
                
                // Проверяем решение каждую секунду
                self.checkSolution()
                
                if self.timeRemaining <= 0 {
                    self.endGame(success: false)
                }
            }
        }
    }
    
    func pauseGame() {
        isGamePaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
    }
    
    func movePiece(id: UUID, to position: CGPoint) {
        guard var puzzle = currentPuzzle,
              let index = puzzle.currentArrangement.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var newPosition = position
        var didSnap = false
        
        // Магнитное прилипание
        if let targetIndex = puzzle.targetPattern.firstIndex(where: { $0.id == id }) {
            let target = puzzle.targetPattern[targetIndex]
            let currentPiece = puzzle.currentArrangement[index]
            
            // Проверяем расстояние до целевой позиции
            let distance = sqrt(
                pow(position.x - target.position.x, 2) +
                pow(position.y - target.position.y, 2)
            )
            
            // Для симметричных фигур не проверяем поворот
            var rotationMatch = true
            if target.shape.needsRotation {
                let rotationDiff = abs(currentPiece.rotation - target.rotation).truncatingRemainder(dividingBy: 360)
                rotationMatch = rotationDiff < 30 || rotationDiff > 330
            }
            
            // Если близко (60 пикселей) и поворот правильный - примагничиваем
            if distance < 60 && rotationMatch {
                newPosition = target.position
                // Для несимметричных фигур также выставляем точный поворот
                if target.shape.needsRotation {
                    puzzle.currentArrangement[index].rotation = target.rotation
                }
                didSnap = true
                print("🧲 Snapped piece \(id) to target position")
            }
        }
        
        puzzle.currentArrangement[index].position = newPosition
        currentPuzzle = puzzle
        
        // Если примагнитили - проверяем сразу дважды для надёжности
        if didSnap {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkSolution()
            }
        }
        
        checkSolution()
    }
    
    func rotatePiece(id: UUID) {
        guard var puzzle = currentPuzzle,
              let index = puzzle.currentArrangement.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        // Не вращаем симметричные фигуры (например, круг)
        let currentShape = puzzle.currentArrangement[index].shape
        if !currentShape.needsRotation {
            print("⭕️ Shape \(currentShape) is symmetric, rotation skipped")
            return
        }
        
        // Поворачиваем на 45 градусов
        puzzle.currentArrangement[index].rotation += 45
        if puzzle.currentArrangement[index].rotation >= 360 {
            puzzle.currentArrangement[index].rotation = 0
        }
        
        var didSnap = false
        
        // Проверяем, нужно ли примагнитить после поворота
        if let targetIndex = puzzle.targetPattern.firstIndex(where: { $0.id == id }) {
            let target = puzzle.targetPattern[targetIndex]
            let currentPiece = puzzle.currentArrangement[index]
            
            // Расстояние до цели
            let distance = sqrt(
                pow(currentPiece.position.x - target.position.x, 2) +
                pow(currentPiece.position.y - target.position.y, 2)
            )
            
            // Проверяем совпадение поворота
            let rotationDiff = abs(currentPiece.rotation - target.rotation).truncatingRemainder(dividingBy: 360)
            let rotationMatch = rotationDiff < 30 || rotationDiff > 330
            
            // Если близко и поворот правильный - примагничиваем позицию и поворот
            if distance < 60 && rotationMatch {
                puzzle.currentArrangement[index].position = target.position
                puzzle.currentArrangement[index].rotation = target.rotation
                didSnap = true
                print("🧲 Snapped piece \(id) after rotation")
            }
        }
        
        currentPuzzle = puzzle
        
        // Если примагнитили - проверяем сразу дважды для надёжности
        if didSnap {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.checkSolution()
            }
        }
        
        checkSolution()
    }
    
    func selectPiece(id: UUID) {
        selectedPieceId = id
    }
    
    private func checkSolution() {
        guard let puzzle = currentPuzzle else { return }
        
        let isSolved = puzzle.checkSolution()
        print("🔍 Checking solution: \(isSolved)")
        
        if isSolved {
            endGame(success: true)
        }
    }
    
    private func endGame(success: Bool) {
        print("🎮 End game called - success: \(success)")
        isGameActive = false
        timer?.invalidate()
        
        if success {
            calculateScore()
            user.completeLevel()
            streakBonus = calculateStreakBonus()
            
            print("🎉 Setting showCompletionAlert to true")
            // Небольшая задержка чтобы UI успел обновиться
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showCompletionAlert = true
                print("✅ showCompletionAlert is now: \(self?.showCompletionAlert ?? false)")
            }
        } else {
            user.failLevel()
            streakBonus = 0
            
            print("⏰ Setting showFailureAlert to true")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showFailureAlert = true
                print("❌ showFailureAlert is now: \(self?.showFailureAlert ?? false)")
            }
        }
    }
    
    private func calculateScore() {
        guard let puzzle = currentPuzzle else { return }
        
        let baseScore = puzzle.difficulty.pieceCount * 100
        let timeBonus = Int(timeRemaining) * 10
        let levelMultiplier = currentLevel
        
        let totalScore = (baseScore + timeBonus) * levelMultiplier
        score += totalScore
        user.updateScore(points: totalScore)
    }
    
    private func calculateStreakBonus() -> Int {
        let streak = user.currentStreak
        if streak >= 10 {
            return 500
        } else if streak >= 5 {
            return 250
        } else if streak >= 3 {
            return 100
        }
        return 0
    }
    
    func resetGame() {
        currentLevel = 1
        score = 0
        isGameActive = false
        isGamePaused = false
        currentPuzzle = nil
        timer?.invalidate()
    }
    
    func getHint() -> UUID? {
        guard let puzzle = currentPuzzle else { return nil }
        
        // Find the first piece that's not in correct position
        for (current, target) in zip(puzzle.currentArrangement, puzzle.targetPattern) {
            let positionMatch = abs(current.position.x - target.position.x) < 30 &&
                                abs(current.position.y - target.position.y) < 30
            
            if !positionMatch {
                return current.id
            }
        }
        return nil
    }
}

