//
//  PuzzleBoardView.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI

struct PuzzleBoardView: View {
    let puzzle: Puzzle
    @Binding var selectedPieceId: UUID?
    let onMovePiece: (UUID, CGPoint) -> Void
    let onRotatePiece: (UUID) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Игровая область с ограничениями
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: geometry.size.width, height: min(geometry.size.height, 500))
                
                // Target Pattern (Ghost view) - более заметный
                ForEach(puzzle.targetPattern) { piece in
                    piece.shape.path
                        .fill(piece.color.color.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            piece.shape.path
                                .stroke(piece.color.color, lineWidth: 2)
                                .frame(width: 60, height: 60)
                        )
                        .rotationEffect(.degrees(piece.rotation))
                        .position(piece.position)
                }
                
                // Hint Text
                Text("Match colored shapes with ghost outlines")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .position(x: geometry.size.width / 2, y: 30)
                
                // Current Arrangement (Interactive pieces)
                ForEach(puzzle.currentArrangement) { piece in
                    PuzzlePieceView(
                        piece: piece,
                        isSelected: selectedPieceId == piece.id,
                        onTap: {
                            onRotatePiece(piece.id)
                        }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                selectedPieceId = piece.id
                                // Ограничиваем перемещение по Y (не ниже 400)
                                let clampedY = min(value.location.y, 400)
                                let clampedX = max(50, min(value.location.x, geometry.size.width - 50))
                                onMovePiece(piece.id, CGPoint(x: clampedX, y: clampedY))
                            }
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Puzzle Piece View
struct PuzzlePieceView: View {
    let piece: PuzzlePiece
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // Shadow/Glow effect for selected piece
            if isSelected {
                piece.shape.path
                    .fill(piece.color.color)
                    .frame(width: 70, height: 70)
                    .blur(radius: 10)
                    .opacity(0.6)
            }
            
            // Actual piece
            piece.shape.path
                .fill(piece.color.color)
                .frame(width: 60, height: 60)
                .overlay(
                    piece.shape.path
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .rotationEffect(.degrees(piece.rotation))
        .position(piece.position)
        .onTapGesture {
            onTap()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: piece.rotation)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: piece.position)
    }
}

