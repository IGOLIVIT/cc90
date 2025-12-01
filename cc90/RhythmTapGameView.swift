//
//  RhythmTapGameView.swift
//  cc90
//

import SwiftUI

struct RhythmTapGameView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var gameState: GameState = .idle
    @State private var markers: [Marker] = []
    @State private var score: Int = 0
    @State private var perfectHits: Int = 0
    @State private var goodHits: Int = 0
    @State private var missedHits: Int = 0
    @State private var totalMarkers: Int = 0
    @State private var showReward = false
    @State private var gameTimer: Timer?
    @State private var spawnedCount: Int = 0
    
    enum GameState {
        case idle, playing, finished
    }
    
    struct Marker: Identifiable {
        let id = UUID()
        var xPosition: CGFloat
        var isHit: Bool = false
        var isScored: Bool = false // Чтобы не считать дважды
    }
    
    let targetX: CGFloat = 0.5
    let perfectZone: CGFloat = 0.04
    let goodZone: CGFloat = 0.12
    let markerSpeed: CGFloat = 0.008 // Пиксели за кадр (нормализовано)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instructions
                if gameState == .idle {
                    Text("Synchronize with energy pulses! Tap when orbs reach the sync line.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // Score display
                if gameState == .playing || gameState == .finished {
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(perfectHits)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("AccentGreen"))
                            Text("Perfect")
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        
                        VStack {
                            Text("\(goodHits)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("HighlightYellow"))
                            Text("Good")
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary"))
                        }
                        
                        VStack {
                            Text("\(missedHits)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color("SoftOrange"))
                            Text("Missed")
                                .font(.system(size: 12))
                                .foregroundColor(Color("TextSecondary"))
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Game area
                GeometryReader { geometry in
                    ZStack {
                        // Background track
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("SecondaryBackground"))
                        
                        // Safe zone indicator (визуальная подсказка)
                        Rectangle()
                            .fill(Color("AccentGreen").opacity(0.2))
                            .frame(width: geometry.size.width * (goodZone * 2))
                            .position(x: geometry.size.width * targetX, y: geometry.size.height / 2)
                        
                        // Perfect zone
                        Rectangle()
                            .fill(Color("AccentGreen").opacity(0.4))
                            .frame(width: geometry.size.width * (perfectZone * 2))
                            .position(x: geometry.size.width * targetX, y: geometry.size.height / 2)
                        
                        // Target line
                        Rectangle()
                            .fill(Color("AccentGreen"))
                            .frame(width: 4, height: geometry.size.height)
                            .position(x: geometry.size.width * targetX, y: geometry.size.height / 2)
                        
                        // Markers
                        ForEach(markers) { marker in
                            if !marker.isHit {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("SoftOrange"), Color("HighlightYellow")],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Text("⚡️")
                                        .font(.system(size: 20))
                                }
                                .position(
                                    x: geometry.size.width * marker.xPosition,
                                    y: geometry.size.height / 2
                                )
                            }
                        }
                    }
                }
                .frame(height: 400)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
                .onTapGesture {
                    if gameState == .playing {
                        handleTap()
                    }
                }
                
                // Control buttons
                if gameState == .idle {
                    Button(action: startGame) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("PrimaryBackground"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("SoftOrange"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                } else if gameState == .finished {
                    VStack(spacing: 16) {
                        Text("Complete! 🎵")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("SoftOrange"))
                        
                        if showReward {
                            HStack(spacing: 20) {
                                HStack {
                                    Text("💎")
                                    Text("+\(score)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("TextPrimary"))
                                }
                                HStack {
                                    Text("⭐️")
                                    Text("+\(max(1, score / 2))")
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
        .navigationTitle("Pulse Sync")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            stopGame()
        }
    }
    
    func startGame() {
        stopGame()
        
        gameState = .playing
        markers = []
        score = 0
        perfectHits = 0
        goodHits = 0
        missedHits = 0
        totalMarkers = 12
        spawnedCount = 0
        showReward = false
        
        // Spawn markers с интервалом
        var spawnDelay = 0.0
        for _ in 0..<totalMarkers {
            DispatchQueue.main.asyncAfter(deadline: .now() + spawnDelay) {
                if gameState == .playing {
                    spawnMarker()
                }
            }
            spawnDelay += 1.5 // Интервал между маркерами
        }
        
        // Start game loop - 60 FPS
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            if gameState == .playing {
                updateGame()
            }
        }
        
        // End game after all markers + время на последний маркер
        let gameDuration = Double(totalMarkers) * 1.5 + 3.0
        DispatchQueue.main.asyncAfter(deadline: .now() + gameDuration) {
            if gameState == .playing {
                finishGame()
            }
        }
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func spawnMarker() {
        markers.append(Marker(xPosition: 0, isHit: false, isScored: false))
        spawnedCount += 1
    }
    
    func updateGame() {
        // Move markers
        for index in markers.indices {
            if !markers[index].isHit {
                markers[index].xPosition += markerSpeed
                
                // Auto-miss если прошёл зону
                if markers[index].xPosition > targetX + goodZone && !markers[index].isScored {
                    markers[index].isScored = true
                    missedHits += 1
                }
            }
        }
        
        // Remove far markers
        markers.removeAll { $0.xPosition > 1.2 }
    }
    
    func handleTap() {
        // Find the closest marker to target within hit range
        var closestMarker: (index: Int, distance: CGFloat)? = nil
        
        for (index, marker) in markers.enumerated() {
            if !marker.isHit && !marker.isScored {
                let distance = abs(marker.xPosition - targetX)
                
                // Только если в зоне досягаемости
                if distance <= goodZone {
                    if let closest = closestMarker {
                        if distance < closest.distance {
                            closestMarker = (index, distance)
                        }
                    } else {
                        closestMarker = (index, distance)
                    }
                }
            }
        }
        
        guard let closest = closestMarker else { return }
        
        let distance = closest.distance
        markers[closest.index].isHit = true
        markers[closest.index].isScored = true
        
        if distance <= perfectZone {
            perfectHits += 1
            score += 3
        } else if distance <= goodZone {
            goodHits += 1
            score += 1
        }
    }
    
    func finishGame() {
        stopGame()
        gameState = .finished
        
        let feathers = score
        let lanterns = max(1, score / 2)
        progressStore.earnReward(feathers: feathers, lanterns: lanterns)
        progressStore.updateBestStreak(gameNumber: 3, streak: perfectHits)
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
            showReward = true
        }
    }
}
