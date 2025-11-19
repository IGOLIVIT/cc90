//
//  MemoryPathGameView.swift
//  cc90
//

import SwiftUI

struct MemoryPathGameView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var gameState: GameState = .idle
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var highlightedTile: Int? = nil
    @State private var tileStates: [TileState] = Array(repeating: .normal, count: 9)
    @State private var currentLevel: Int = 1
    @State private var showReward = false
    @State private var isUserInteractionEnabled = false
    
    enum GameState {
        case idle, showing, waiting, won, lost
    }
    
    enum TileState {
        case normal, highlighted, correct, wrong
    }
    
    let gridSize = 3
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instructions
                if gameState == .idle {
                    Text("Watch the crystals light up, then tap them in the same order!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // Level indicator
                Text("Level \(currentLevel)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .padding(.top, 20)
                
                // Status message
                if gameState == .showing {
                    Text("Watch carefully...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("HighlightYellow"))
                } else if gameState == .waiting {
                    Text("Your turn! Tap in order")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("AccentGreen"))
                }
                
                // Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: gridSize), spacing: 12) {
                    ForEach(0..<9, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tileColor(for: index))
                            .frame(height: 100)
                            .overlay(
                                tileIcon(for: index)
                            )
                            .scaleEffect(highlightedTile == index ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: highlightedTile)
                            .onTapGesture {
                                if isUserInteractionEnabled && gameState == .waiting {
                                    handleTileTap(index)
                                }
                            }
                            .disabled(!isUserInteractionEnabled || gameState != .waiting)
                    }
                }
                .padding(.horizontal, 20)
                
                // Control buttons
                if gameState == .idle {
                    Button(action: startGame) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color("PrimaryBackground"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("HighlightYellow"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                } else if gameState == .won {
                    VStack(spacing: 16) {
                        Text("Perfect! ✨")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("HighlightYellow"))
                        
                        if showReward {
                            HStack(spacing: 20) {
                                HStack {
                                    Text("💎")
                                    Text("+\(currentLevel * 2)")
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
                                Text("Next level")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color("PrimaryBackground"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color("HighlightYellow"))
                                    .cornerRadius(16)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
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
                } else if gameState == .lost {
                    VStack(spacing: 16) {
                        Text("Almost there!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("SoftOrange"))
                        
                        Button(action: retryLevel) {
                            Text("Try again")
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
        .navigationTitle("Memory Path")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func tileColor(for index: Int) -> Color {
        switch tileStates[index] {
        case .normal:
            return Color("SecondaryBackground")
        case .highlighted:
            return Color("HighlightYellow")
        case .correct:
            return Color("AccentGreen")
        case .wrong:
            return Color("SoftOrange")
        }
    }
    
    func tileIcon(for index: Int) -> some View {
        Group {
            if tileStates[index] == .highlighted {
                Text("💎")
                    .font(.system(size: 32))
            } else if tileStates[index] == .correct {
                Text("✓")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            } else if tileStates[index] == .wrong {
                Text("✗")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
            }
        }
    }
    
    func startGame() {
        currentLevel = 1
        playRound()
    }
    
    func retryLevel() {
        playRound()
    }
    
    func nextLevel() {
        currentLevel += 1
        showReward = false
        playRound()
    }
    
    func playRound() {
        gameState = .showing
        playerSequence = []
        tileStates = Array(repeating: .normal, count: 9)
        isUserInteractionEnabled = false
        
        // Generate sequence: начинаем с 3, добавляем 1 каждые 2 уровня
        let sequenceLength = min(3 + (currentLevel - 1) / 2, 7)
        sequence = []
        
        // Генерируем уникальную последовательность без повторов подряд
        var lastIndex = -1
        for _ in 0..<sequenceLength {
            var newIndex: Int
            repeat {
                newIndex = Int.random(in: 0..<9)
            } while newIndex == lastIndex && sequenceLength > 1
            
            sequence.append(newIndex)
            lastIndex = newIndex
        }
        
        // Show sequence after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSequence()
        }
    }
    
    func showSequence() {
        var delay = 0.0
        
        for (index, tile) in sequence.enumerated() {
            // Highlight tile
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                highlightedTile = tile
                tileStates[tile] = .highlighted
            }
            
            // Remove highlight
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
                highlightedTile = nil
                tileStates[tile] = .normal
                
                // After last tile, enable player input
                if index == sequence.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        gameState = .waiting
                        isUserInteractionEnabled = true
                    }
                }
            }
            
            delay += 1.0
        }
    }
    
    func handleTileTap(_ index: Int) {
        guard isUserInteractionEnabled else { return }
        
        playerSequence.append(index)
        
        let currentIndex = playerSequence.count - 1
        
        if playerSequence[currentIndex] == sequence[currentIndex] {
            // Correct!
            tileStates[index] = .correct
            
            // Check if completed
            if playerSequence.count == sequence.count {
                isUserInteractionEnabled = false
                gameState = .won
                let feathers = currentLevel * 2
                let lanterns = currentLevel
                progressStore.earnReward(feathers: feathers, lanterns: lanterns)
                progressStore.updateBestStreak(gameNumber: 2, streak: currentLevel)
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5)) {
                    showReward = true
                }
            }
        } else {
            // Wrong!
            isUserInteractionEnabled = false
            tileStates[index] = .wrong
            
            // Show correct sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for (seqIndex, tileIndex) in sequence.enumerated() {
                    if seqIndex < playerSequence.count {
                        tileStates[tileIndex] = playerSequence[seqIndex] == tileIndex ? .correct : .wrong
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                gameState = .lost
            }
        }
    }
}
