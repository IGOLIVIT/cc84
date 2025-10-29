//
//  OnboardingView.swift
//  CognifyQuest
//
//  Created by IGOR on 29/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @ObservedObject var appState: AppState
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var showProfileSetup = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            if !showProfileSetup {
                VStack(spacing: 0) {
                    // Page Content
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(0..<viewModel.instructionPages.count, id: \.self) { index in
                            InstructionCardView(page: viewModel.instructionPages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    // Navigation Buttons
                    HStack(spacing: 15) {
                        if viewModel.currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    viewModel.previousPage()
                                }
                            }) {
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            if viewModel.isLastPage {
                                withAnimation {
                                    showProfileSetup = true
                                }
                            } else {
                                withAnimation {
                                    viewModel.nextPage()
                                }
                            }
                        }) {
                            Text(viewModel.isLastPage ? "Get Started" : "Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#06dbab"), Color(hex: "#ff2300")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            } else {
                // Profile Setup Screen
                ProfileSetupView(
                    viewModel: viewModel,
                    onComplete: {
                        let user = viewModel.completeOnboarding()
                        appState.updateUser(user)
                        
                        // Save user data
                        if let data = try? JSONEncoder().encode(user),
                           let string = String(data: data, encoding: .utf8) {
                            UserDefaults.standard.set(string, forKey: "userData")
                        }
                        
                        withAnimation {
                            isOnboardingComplete = true
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Profile Setup View
struct ProfileSetupView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Title
            VStack(spacing: 10) {
                Text("Create Your Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Choose your avatar and name")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Avatar Selection
            VStack(spacing: 15) {
                Text("Select Avatar")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#06dbab"))
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(AvatarEmoji.allCases, id: \.self) { avatar in
                            Button(action: {
                                viewModel.selectedAvatar = avatar.emoji
                            }) {
                                Text(avatar.emoji)
                                    .font(.system(size: 50))
                                    .frame(width: 80, height: 80)
                                    .background(
                                        viewModel.selectedAvatar == avatar.emoji ?
                                        Color(hex: "#06dbab").opacity(0.3) :
                                        Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(
                                                viewModel.selectedAvatar == avatar.emoji ?
                                                Color(hex: "#06dbab") : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Username Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Your Name")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#06dbab"))
                    .padding(.horizontal, 20)
                
                TextField("Enter your name", text: $viewModel.username)
                    .font(.title3)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#06dbab").opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
            }
            
            // Start Button
            Button(action: onComplete) {
                Text("Start Playing")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#06dbab"), Color(hex: "#ff2300")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .disabled(viewModel.username.isEmpty)
            .opacity(viewModel.username.isEmpty ? 0.5 : 1.0)
            
            Spacer()
        }
    }
}

