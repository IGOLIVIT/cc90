//
//  CrystalMemoryGameView.swift
//  cc90
//

import SwiftUI

struct CrystalMemoryGameView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var gameState: GameState = .idle
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var highlightedCrystal: Int? = nil
    @State private var crystalStates: [CrystalState] = Array(repeating: .normal, count: 9)
    @State private var currentLevel: Int = 1
    @State private var showReward = false
    @State private var isUserInteractionEnabled = false
    @State private var rotationAngles: [Double] = Array(repeating: 0, count: 9)
    
    enum GameState {
        case idle, showing, waiting, won, lost
    }
    
    enum CrystalState {
        case normal, highlighted, correct, wrong
    }
    
    let gridSize = 3
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Instructions
                if gameState == .idle {
                    Text("Crystal sequence challenge! Watch them glow, then match the pattern.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                
                // Level indicator
                HStack(spacing: 12) {
                    Text("💎")
                        .font(.system(size: 24))
                    
                    Text("Level \(currentLevel)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.top, 20)
                
                // Status message
                if gameState == .showing {
                    Text("Watch carefully...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("HighlightYellow"))
                        .transition(.opacity)
                } else if gameState == .waiting {
                    Text("Your turn! Tap in order")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("AccentGreen"))
                        .transition(.opacity)
                }
                
                // Crystal Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: gridSize), spacing: 16) {
                    ForEach(0..<9, id: \.self) { index in
                        CrystalView(
                            state: crystalStates[index],
                            isHighlighted: highlightedCrystal == index,
                            rotationAngle: rotationAngles[index]
                        )
                        .onTapGesture {
                            if isUserInteractionEnabled && gameState == .waiting {
                                handleCrystalTap(index)
                            }
                        }
                        .disabled(!isUserInteractionEnabled || gameState != .waiting)
                    }
                }
                .padding(.horizontal, 20)
                
                // Control buttons
                if gameState == .idle {
                    Button(action: startGame) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color("PrimaryBackground"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color("HighlightYellow"), Color("SoftOrange")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color("HighlightYellow").opacity(0.3), radius: 10, y: 5)
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
                                HStack(spacing: 8) {
                                    Text("Next level")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("PrimaryBackground"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color("HighlightYellow"))
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
                } else if gameState == .lost {
                    VStack(spacing: 16) {
                        Text("Almost there!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("SoftOrange"))
                        
                        Button(action: retryLevel) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Try again")
                            }
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
        .navigationTitle("Crystal Memory")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startRotationAnimation()
        }
    }
    
    func startRotationAnimation() {
        for index in 0..<9 {
            withAnimation(.linear(duration: 3.0 + Double(index) * 0.2).repeatForever(autoreverses: false)) {
                rotationAngles[index] = 360
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
        crystalStates = Array(repeating: .normal, count: 9)
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
        
        for (index, crystal) in sequence.enumerated() {
            // Highlight crystal
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    highlightedCrystal = crystal
                    crystalStates[crystal] = .highlighted
                }
            }
            
            // Remove highlight
            DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.6) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    highlightedCrystal = nil
                    crystalStates[crystal] = .normal
                }
                
                // After last crystal, enable player input
                if index == sequence.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                            gameState = .waiting
                            isUserInteractionEnabled = true
                        }
                    }
                }
            }
            
            delay += 1.0
        }
    }
    
    func handleCrystalTap(_ index: Int) {
        guard isUserInteractionEnabled else { return }
        
        playerSequence.append(index)
        
        let currentIndex = playerSequence.count - 1
        
        if playerSequence[currentIndex] == sequence[currentIndex] {
            // Correct!
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                crystalStates[index] = .correct
            }
            
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
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                crystalStates[index] = .wrong
            }
            
            // Show correct sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                for (seqIndex, crystalIndex) in sequence.enumerated() {
                    if seqIndex < playerSequence.count {
                        crystalStates[crystalIndex] = playerSequence[seqIndex] == crystalIndex ? .correct : .wrong
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                gameState = .lost
            }
        }
    }
}

// MARK: - 3D Crystal View
struct CrystalView: View {
    let state: CrystalMemoryGameView.CrystalState
    let isHighlighted: Bool
    let rotationAngle: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Outer glow
                if isHighlighted {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    crystalColor.opacity(0.6),
                                    crystalColor.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .blur(radius: 10)
                }
                
                // 3D Crystal shape
                ZStack {
                    // Back facets
                    CrystalFacet(offset: -8, opacity: 0.3)
                        .fill(crystalColor.opacity(0.4))
                        .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0))
                    
                    // Middle facets
                    CrystalFacet(offset: -4, opacity: 0.5)
                        .fill(crystalColor.opacity(0.6))
                        .rotation3DEffect(.degrees(rotationAngle * 0.8), axis: (x: 0, y: 1, z: 0))
                    
                    // Front facet (main)
                    CrystalFacet(offset: 0, opacity: 1.0)
                        .fill(
                            LinearGradient(
                                colors: [
                                    crystalColor.opacity(0.8),
                                    crystalColor,
                                    crystalColor.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotation3DEffect(.degrees(rotationAngle * 0.6), axis: (x: 0, y: 1, z: 0))
                    
                    // Highlight shine
                    if isHighlighted || state == .highlighted {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.white.opacity(0.8), Color.clear],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 30, height: 30)
                            .offset(x: -15, y: -15)
                    }
                    
                    // State icon
                    if state == .correct {
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    } else if state == .wrong {
                        Image(systemName: "xmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .shadow(color: crystalColor.opacity(0.5), radius: isHighlighted ? 15 : 5, y: isHighlighted ? 8 : 3)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHighlighted)
    }
    
    var crystalColor: Color {
        switch state {
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
}

// MARK: - Crystal Facet Shape
struct CrystalFacet: Shape {
    let offset: CGFloat
    let opacity: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        
        // Create hexagonal crystal shape
        let points = (0..<6).map { index -> CGPoint in
            let angle = CGFloat(index) * .pi / 3 - .pi / 2
            return CGPoint(
                x: center.x + cos(angle) * (radius + offset),
                y: center.y + sin(angle) * (radius + offset)
            )
        }
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        return path
    }
}


