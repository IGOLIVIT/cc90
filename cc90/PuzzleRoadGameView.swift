//
//  PuzzleRoadGameView.swift
//  cc90
//

import SwiftUI

struct PuzzleRoadGameView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var gameState: GameState = .idle
    @State private var roadSlots: [RoadTile?] = Array(repeating: nil, count: 6)
    @State private var availableTiles: [RoadTile] = []
    @State private var currentLevel: Int = 1
    @State private var moveCount: Int = 0
    @State private var showReward = false
    @State private var showSuccess = false
    @State private var selectedTileIndex: Int? = nil
    
    enum GameState {
        case idle, playing, won
    }
    
    struct RoadTile: Identifiable, Equatable {
        let id = UUID()
        let type: TileType
        
        enum TileType: String, CaseIterable {
            case energy = "⚡️"
            case crystal = "💎"
            case star = "⭐️"
            
            var displayName: String {
                switch self {
                case .energy: return "Energy"
                case .crystal: return "Crystal"
                case .star: return "Star"
                }
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instructions
                if gameState == .idle {
                    Text("Build an energy matrix! Select and place crystals to complete the circuit.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // Level and moves
                HStack(spacing: 30) {
                    VStack {
                        Text("Level \(currentLevel)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("TextPrimary"))
                        Text("Current")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                    
                    VStack {
                        Text("\(moveCount)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("HighlightYellow"))
                        Text("Moves")
                            .font(.system(size: 12))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .padding(.top, 20)
                
                // Road area with slots
                VStack(spacing: 12) {
                    // Start: Player
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color("HighlightYellow"))
                                .frame(width: 50, height: 50)
                            
                            Text("🔮")
                                .font(.system(size: 28))
                        }
                        Spacer()
                    }
                    
                    // Road slots
                    ForEach(0..<6, id: \.self) { index in
                        Button(action: {
                            handleSlotTap(index: index)
                        }) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(roadSlots[index] != nil ? Color("AccentGreen").opacity(0.3) : Color("SecondaryBackground"))
                                .frame(height: 80)
                                .overlay(
                                    Group {
                                        if let tile = roadSlots[index] {
                                            VStack(spacing: 4) {
                                                Text(tile.type.rawValue)
                                                    .font(.system(size: 36))
                                                
                                                Text(tile.type.displayName)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color("TextSecondary"))
                                            }
                                        } else {
                                            Text("Tap to place")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color("TextSecondary"))
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            roadSlots[index] != nil ? Color("AccentGreen") : Color("TextSecondary").opacity(0.3),
                                            lineWidth: 2
                                        )
                                )
                        }
                        .disabled(gameState != .playing)
                    }
                    
                    // End: Goal
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color("AccentGreen"))
                                .frame(width: 50, height: 50)
                            
                            Text("✨")
                                .font(.system(size: 28))
                        }
                        Spacer()
                    }
                    
                    if showSuccess {
                        Text("Path Complete! ✨")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("AccentGreen"))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                
                // Available tiles
                if gameState == .playing && !availableTiles.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available tiles (tap to select):")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(availableTiles.enumerated()), id: \.element.id) { index, tile in
                                    Button(action: {
                                        selectedTileIndex = index
                                    }) {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                selectedTileIndex == index ?
                                                Color("HighlightYellow").opacity(0.3) :
                                                Color("SecondaryBackground")
                                            )
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                VStack(spacing: 4) {
                                                    Text(tile.type.rawValue)
                                                        .font(.system(size: 32))
                                                    
                                                    Text(tile.type.displayName)
                                                        .font(.system(size: 10))
                                                        .foregroundColor(Color("TextSecondary"))
                                                }
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        selectedTileIndex == index ?
                                                        Color("HighlightYellow") :
                                                        Color.clear,
                                                        lineWidth: 3
                                                    )
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
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
                            .background(Color("AccentGreen"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                } else if gameState == .playing {
                    HStack(spacing: 12) {
                        Button(action: checkSolution) {
                            Text("Check path")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("PrimaryBackground"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("AccentGreen"))
                                .cornerRadius(16)
                        }
                        
                        Button(action: resetPuzzle) {
                            Text("Reset")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("TextPrimary"))
                                .frame(width: 100)
                                .frame(height: 54)
                                .background(Color("SecondaryBackground"))
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                } else if gameState == .won {
                    VStack(spacing: 16) {
                        Text("Perfect! ✨")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("AccentGreen"))
                        
                        if showReward {
                            HStack(spacing: 20) {
                                HStack {
                                    Text("💎")
                                    Text("+\(max(3, 10 - moveCount))")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("TextPrimary"))
                                }
                                HStack {
                                    Text("⭐️")
                                    Text("+\(currentLevel)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color("TextPrimary"))
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: nextLevel) {
                                Text("Next")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("PrimaryBackground"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color("AccentGreen"))
                                    .cornerRadius(16)
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Finish")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("TextPrimary"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color("SecondaryBackground"))
                                    .cornerRadius(16)
                            }
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
        .navigationTitle("Matrix Build")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func handleSlotTap(index: Int) {
        guard gameState == .playing else { return }
        
        // If slot is empty and we have a tile selected, place it
        if roadSlots[index] == nil, let selectedIndex = selectedTileIndex, selectedIndex < availableTiles.count {
            roadSlots[index] = availableTiles[selectedIndex]
            availableTiles.remove(at: selectedIndex)
            selectedTileIndex = nil
            moveCount += 1
        }
        // If slot is filled, remove tile back to available
        else if roadSlots[index] != nil {
            if let tile = roadSlots[index] {
                availableTiles.append(tile)
                roadSlots[index] = nil
            }
        }
    }
    
    func startGame() {
        currentLevel = 1
        setupLevel()
    }
    
    func nextLevel() {
        currentLevel += 1
        showReward = false
        showSuccess = false
        setupLevel()
    }
    
    func setupLevel() {
        gameState = .playing
        roadSlots = Array(repeating: nil, count: 6)
        moveCount = 0
        selectedTileIndex = nil
        
        // Generate tiles - чем выше уровень, тем больше плиток
        availableTiles = []
        let tilesNeeded = 6 // Всегда заполняем все слоты
        
        for _ in 0..<tilesNeeded {
            let randomType = RoadTile.TileType.allCases.randomElement()!
            availableTiles.append(RoadTile(type: randomType))
        }
        
        availableTiles.shuffle()
    }
    
    func resetPuzzle() {
        // Return tiles to available
        for slot in roadSlots {
            if let tile = slot {
                availableTiles.append(tile)
            }
        }
        roadSlots = Array(repeating: nil, count: 6)
        moveCount = 0
        selectedTileIndex = nil
    }
    
    func checkSolution() {
        // Check if all slots are filled
        let allFilled = roadSlots.allSatisfy { $0 != nil }
        
        if allFilled {
            gameState = .won
            showSuccess = true
            
            let feathers = max(3, 10 - moveCount)
            let lanterns = currentLevel
            progressStore.earnReward(feathers: feathers, lanterns: lanterns)
            progressStore.updateBestStreak(gameNumber: 4, streak: currentLevel)
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                showReward = true
            }
        }
    }
}
