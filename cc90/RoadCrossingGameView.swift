//
//  RoadCrossingGameView.swift
//  cc90
//

import SwiftUI

struct RoadCrossingGameView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var gameState: GameState = .idle
    @State private var playerLane: Int = 1
    @State private var progress: CGFloat = 0
    @State private var obstacles: [Obstacle] = []
    @State private var score: Int = 0
    @State private var showReward = false
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    
    let numberOfLanes = 3
    let targetProgress: CGFloat = 1.0
    
    enum GameState {
        case idle, playing, won, lost
    }
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var lane: Int
        var yOffset: CGFloat
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instructions
                if gameState == .idle {
                    Text("Navigate energy streams! Swipe to change lanes and avoid discharge obstacles.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("SecondaryBackground"))
                            .frame(height: 16)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("AccentGreen"))
                            .frame(width: geometry.size.width * progress, height: 16)
                    }
                }
                .frame(height: 16)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Game area
                ZStack {
                    // Road background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("SecondaryBackground"))
                    
                    // Lane dividers
                    HStack(spacing: 0) {
                        ForEach(0..<numberOfLanes, id: \.self) { lane in
                            Rectangle()
                                .fill(Color.clear)
                                .overlay(
                                    Rectangle()
                                        .fill(Color("TextSecondary").opacity(0.3))
                                        .frame(width: 2)
                                    , alignment: .trailing
                                )
                        }
                    }
                    
                    // Obstacles
                    GeometryReader { geometry in
                        let laneWidth = geometry.size.width / CGFloat(numberOfLanes)
                        
                        ForEach(obstacles) { obstacle in
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("SoftOrange"))
                                    .frame(width: laneWidth * 0.6, height: 50)
                                
                                Text("⚡️")
                                    .font(.system(size: 24))
                            }
                            .position(
                                x: laneWidth * CGFloat(obstacle.lane) + laneWidth / 2,
                                y: obstacle.yOffset
                            )
                        }
                        
                        // Player
                        if gameState != .idle {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color("HighlightYellow"), Color("AccentGreen")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 50, height: 50)
                                
                                Text("💎")
                                    .font(.system(size: 28))
                            }
                            .position(
                                x: laneWidth * CGFloat(playerLane) + laneWidth / 2,
                                y: geometry.size.height - 80
                            )
                        }
                    }
                }
                .frame(height: 500)
                .padding(.horizontal, 20)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if gameState == .playing {
                                if value.translation.width > 0 && playerLane < numberOfLanes - 1 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        playerLane += 1
                                    }
                                } else if value.translation.width < 0 && playerLane > 0 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        playerLane -= 1
                                    }
                                }
                            }
                        }
                )
                
                // Control buttons
                if gameState == .idle {
                    Button(action: startGame) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("PrimaryBackground"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("AccentGreen"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                } else if gameState == .won {
                    VStack(spacing: 16) {
                        Text("Success! ✨")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("AccentGreen"))
                        
                        if showReward {
                            HStack(spacing: 20) {
                                HStack {
                                    Text("💎")
                                    Text("+5")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("TextPrimary"))
                                }
                                HStack {
                                    Text("⭐️")
                                    Text("+2")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("TextPrimary"))
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        Button(action: startGame) {
                            Text("Play again")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("PrimaryBackground"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("AccentGreen"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                } else if gameState == .lost {
                    VStack(spacing: 16) {
                        Text("Try again!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("SoftOrange"))
                        
                        Button(action: startGame) {
                            Text("Retry")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("PrimaryBackground"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("SoftOrange"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .navigationTitle("Energy Flow")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopGame()
        }
    }
    
    func startGame() {
        stopGame() // Clean up any existing timers
        
        gameState = .playing
        playerLane = 1
        progress = 0
        obstacles = []
        score = 0
        showReward = false
        
        // Start spawning obstacles - каждые 1.2 секунды
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in
            if gameState == .playing {
                spawnObstacle()
            }
        }
        
        // Start game loop - 60 FPS
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            if gameState == .playing {
                updateGame()
            }
        }
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        gameTimer = nil
        spawnTimer = nil
    }
    
    func spawnObstacle() {
        let randomLane = Int.random(in: 0..<numberOfLanes)
        obstacles.append(Obstacle(lane: randomLane, yOffset: -50))
    }
    
    func updateGame() {
        // Move obstacles - скорость 4 пикселя за кадр
        for index in obstacles.indices {
            obstacles[index].yOffset += 4
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.yOffset > 550 }
        
        // Check collisions - улучшенная физика столкновений
        let playerY: CGFloat = 420 // позиция игрока (500 - 80)
        let playerSize: CGFloat = 50
        let obstacleHeight: CGFloat = 50
        
        for obstacle in obstacles {
            if obstacle.lane == playerLane {
                // Проверка по Y с учётом размеров
                let obstacleBottom = obstacle.yOffset + obstacleHeight / 2
                let obstacleTop = obstacle.yOffset - obstacleHeight / 2
                let playerBottom = playerY + playerSize / 2
                let playerTop = playerY - playerSize / 2
                
                // Столкновение если пересекаются границы
                if obstacleBottom >= playerTop && obstacleTop <= playerBottom {
                    gameState = .lost
                    stopGame()
                    return
                }
            }
        }
        
        // Update progress - медленнее для баланса
        progress += 0.002
        
        // Check win condition
        if progress >= targetProgress {
            gameState = .won
            score += 1
            stopGame()
            progressStore.earnReward(feathers: 5, lanterns: 2)
            progressStore.updateBestStreak(gameNumber: 1, streak: score)
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
                showReward = true
            }
        }
    }
}
