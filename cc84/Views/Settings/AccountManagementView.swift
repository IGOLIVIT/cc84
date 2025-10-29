//
//  AccountManagementView.swift
//  CognifyQuest
//
//  Created by IGOR on 28/10/2025.
//

import SwiftUI

struct AccountManagementView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editedUsername: String = ""
    @State private var selectedAvatar: String = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.updateUsername(editedUsername)
                        viewModel.updateAvatar(selectedAvatar)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#06dbab"))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Avatar Display
                Text(selectedAvatar)
                    .font(.system(size: 100))
                    .frame(width: 150, height: 150)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#ff2300").opacity(0.3), Color(hex: "#06dbab").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Username Editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#06dbab"))
                    
                    TextField("Enter your name", text: $editedUsername)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
                
                // Avatar Grid
                VStack(alignment: .leading, spacing: 15) {
                    Text("Choose Avatar")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#06dbab"))
                        .padding(.horizontal, 20)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(AvatarEmoji.allCases, id: \.self) { avatar in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedAvatar = avatar.emoji
                                    }
                                }) {
                                    Text(avatar.emoji)
                                        .font(.system(size: 40))
                                        .frame(width: 60, height: 60)
                                        .background(
                                            selectedAvatar == avatar.emoji ?
                                            Color(hex: "#ff2300").opacity(0.3) :
                                            Color.white.opacity(0.1)
                                        )
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    selectedAvatar == avatar.emoji ?
                                                    Color(hex: "#ff2300") : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                        .scaleEffect(selectedAvatar == avatar.emoji ? 1.1 : 1.0)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                
                // Account Stats Summary
                VStack(spacing: 10) {
                    HStack {
                        VStack {
                            Text("\(viewModel.user.totalScore)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Total Score")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(viewModel.user.levelsCompleted)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Levels")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("\(viewModel.user.longestStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Best Streak")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            editedUsername = viewModel.user.username
            selectedAvatar = viewModel.user.avatarEmoji
        }
    }
}


