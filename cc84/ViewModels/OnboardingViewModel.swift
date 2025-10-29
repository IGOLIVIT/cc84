//
//  OnboardingViewModel.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var username: String = ""
    @Published var selectedAvatar: String = AvatarEmoji.brain.emoji
    
    let instructionPages: [InstructionPage] = [
        InstructionPage(
            title: "Welcome!",
            description: "Enhance your cognitive skills through engaging puzzle challenges",
            iconName: "brain.head.profile",
            color: Color(hex: "#ff2300")
        ),
        InstructionPage(
            title: "Match the Pattern",
            description: "Arrange shapes to match the target pattern within the time limit",
            iconName: "square.grid.3x3",
            color: Color(hex: "#06dbab")
        ),
        InstructionPage(
            title: "Rotate & Position",
            description: "Drag to move pieces and tap to rotate them into place",
            iconName: "arrow.triangle.2.circlepath",
            color: Color(hex: "#FFD700")
        ),
        InstructionPage(
            title: "Build Your Streak",
            description: "Complete consecutive puzzles to earn streak bonuses and climb the ranks",
            iconName: "flame.fill",
            color: Color(hex: "#9B59B6")
        ),
        InstructionPage(
            title: "Personalize Your Profile",
            description: "Choose your avatar and track your progress",
            iconName: "person.crop.circle.fill",
            color: Color(hex: "#3498DB")
        )
    ]
    
    var isLastPage: Bool {
        currentPage == instructionPages.count - 1
    }
    
    func nextPage() {
        if currentPage < instructionPages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
    
    func completeOnboarding() -> User {
        let finalUsername = username.isEmpty ? "Player" : username
        return User(username: finalUsername, avatarEmoji: selectedAvatar)
    }
}

struct InstructionPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let iconName: String
    let color: Color
}

