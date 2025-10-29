//
//  Puzzle.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Shape Types
enum PuzzleShape: String, Codable, CaseIterable {
    case circle
    case square
    case triangle
    case diamond
    case hexagon
    case star
    
    var path: some Shape {
        switch self {
        case .circle:
            return AnyShape(Circle())
        case .square:
            return AnyShape(Rectangle())
        case .triangle:
            return AnyShape(Triangle())
        case .diamond:
            return AnyShape(Diamond())
        case .hexagon:
            return AnyShape(Hexagon())
        case .star:
            return AnyShape(Star())
        }
    }
    
    // Нужно ли проверять поворот для этой фигуры
    var needsRotation: Bool {
        switch self {
        case .circle:
            return false // Круг симметричный, поворот не имеет значения
        default:
            return true
        }
    }
}

// MARK: - Custom Shapes
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: width, y: height * 0.25))
        path.addLine(to: CGPoint(x: width, y: height * 0.75))
        path.addLine(to: CGPoint(x: width * 0.5, y: height))
        path.addLine(to: CGPoint(x: 0, y: height * 0.75))
        path.addLine(to: CGPoint(x: 0, y: height * 0.25))
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let numberOfPoints = 5
        
        for i in 0..<numberOfPoints * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(numberOfPoints) - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct AnyShape: Shape {
    private let _path: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

// MARK: - Puzzle Piece Model
struct PuzzlePiece: Identifiable, Codable, Equatable {
    let id: UUID
    let shape: PuzzleShape
    let color: PuzzleColor
    var position: CGPoint
    var rotation: Double
    
    init(id: UUID = UUID(), shape: PuzzleShape, color: PuzzleColor, position: CGPoint = .zero, rotation: Double = 0) {
        self.id = id
        self.shape = shape
        self.color = color
        self.position = position
        self.rotation = rotation
    }
}

enum PuzzleColor: String, Codable, CaseIterable {
    case primary = "#ff2300"
    case secondary = "#06dbab"
    case accent1 = "#FFD700"
    case accent2 = "#9B59B6"
    case accent3 = "#3498DB"
    
    var color: Color {
        Color(hex: self.rawValue)
    }
}

// MARK: - Puzzle Model
struct Puzzle: Identifiable, Codable {
    let id: UUID
    let level: Int
    let targetPattern: [PuzzlePiece]
    var currentArrangement: [PuzzlePiece]
    let timeLimit: TimeInterval
    let difficulty: Difficulty
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy
        case medium
        case hard
        case expert
        
        var timeMultiplier: Double {
            switch self {
            case .easy: return 1.5
            case .medium: return 1.0
            case .hard: return 0.75
            case .expert: return 0.5
            }
        }
        
        var pieceCount: Int {
            switch self {
            case .easy: return 3
            case .medium: return 5
            case .hard: return 7
            case .expert: return 9
            }
        }
    }
    
    init(level: Int, difficulty: Difficulty) {
        self.id = UUID()
        self.level = level
        self.difficulty = difficulty
        self.timeLimit = Double(difficulty.pieceCount) * 10 * difficulty.timeMultiplier
        
        // Generate target pattern
        var targetPieces: [PuzzlePiece] = []
        let shapes = PuzzleShape.allCases.shuffled()
        let colors = PuzzleColor.allCases.shuffled()
        
        for i in 0..<difficulty.pieceCount {
            let piece = PuzzlePiece(
                shape: shapes[i % shapes.count],
                color: colors[i % colors.count],
                position: Puzzle.generateGridPosition(index: i, totalCount: difficulty.pieceCount),
                rotation: 0
            )
            targetPieces.append(piece)
        }
        
        self.targetPattern = targetPieces
        
        // Shuffle for current arrangement
        var shuffledPieces = targetPieces.map { piece in
            PuzzlePiece(
                id: piece.id,
                shape: piece.shape,
                color: piece.color,
                position: Puzzle.generateRandomPosition(),
                rotation: Double.random(in: 0...360)
            )
        }
        self.currentArrangement = shuffledPieces.shuffled()
    }
    
    static func generateGridPosition(index: Int, totalCount: Int) -> CGPoint {
        let columns = Int(ceil(sqrt(Double(totalCount))))
        let row = index / columns
        let col = index % columns
        let spacing: CGFloat = 90
        let offsetX: CGFloat = 80
        let offsetY: CGFloat = 120
        
        return CGPoint(
            x: offsetX + CGFloat(col) * spacing,
            y: offsetY + CGFloat(row) * spacing
        )
    }
    
    static func generateRandomPosition() -> CGPoint {
        // Ограничиваем область: не ниже 400 по Y (чтобы не уходило под таббар)
        CGPoint(
            x: CGFloat.random(in: 80...280),
            y: CGFloat.random(in: 120...350)
        )
    }
    
    func checkSolution() -> Bool {
        guard currentArrangement.count == targetPattern.count else { return false }
        
        // Проверяем каждую целевую позицию
        for target in targetPattern {
            // Находим соответствующую фигуру в текущем расположении по ID
            guard let current = currentArrangement.first(where: { $0.id == target.id }) else {
                return false
            }
            
            // Проверяем позицию (в пределах 50 пикселей)
            let distanceX = abs(current.position.x - target.position.x)
            let distanceY = abs(current.position.y - target.position.y)
            
            if distanceX > 50 || distanceY > 50 {
                print("❌ Piece \(target.id) position mismatch: distance X=\(distanceX), Y=\(distanceY)")
                return false
            }
            
            // Проверяем поворот только для фигур, которым это нужно
            if target.shape.needsRotation {
                let rotationDiff = abs(current.rotation - target.rotation).truncatingRemainder(dividingBy: 360)
                let normalizedDiff = min(rotationDiff, 360 - rotationDiff)
                
                if normalizedDiff > 35 {
                    print("❌ Piece \(target.id) rotation mismatch: diff=\(normalizedDiff)°")
                    return false
                }
            } else {
                print("⭕️ Piece \(target.id) is symmetric, rotation check skipped")
            }
        }
        
        print("✅ All pieces matched! Solution is correct!")
        return true
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

