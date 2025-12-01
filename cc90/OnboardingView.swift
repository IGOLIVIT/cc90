//
//  OnboardingView.swift
//  cc90
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @State private var currentPage = 0
    @State private var animateElements = false
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on page
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPage1(animateElements: $animateElements)
                        .tag(0)
                    
                    OnboardingPage2(animateElements: $animateElements)
                        .tag(1)
                    
                    OnboardingPage3(animateElements: $animateElements)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom button
                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        progressStore.completeOnboarding()
                        onComplete()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage == 2 ? "Let's Begin" : "Continue")
                            .font(.system(size: 18, weight: .semibold))
                        
                        if currentPage < 2 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(Color("PrimaryBackground"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    )
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .scaleEffect(animateElements ? 1.0 : 0.95)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                animateElements = true
            }
        }
        .onChange(of: currentPage) { _ in
            animateElements = false
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                animateElements = true
            }
        }
    }
    
    var gradientColors: [Color] {
        switch currentPage {
        case 0:
            return [Color("PrimaryBackground"), Color("SecondaryBackground").opacity(0.8)]
        case 1:
            return [Color(hex: "1a1f3a"), Color(hex: "2d1b4e")]
        case 2:
            return [Color(hex: "0f1a2e"), Color(hex: "1e3a5f")]
        default:
            return [Color("PrimaryBackground"), Color("SecondaryBackground")]
        }
    }
}

// MARK: - Page 1: Welcome
struct OnboardingPage1: View {
    @Binding var animateElements: Bool
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                // Animated hero icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color("HighlightYellow"), Color("SoftOrange")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 40)
                        .offset(y: floatingOffset)
                    
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("HighlightYellow"), Color.white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color("HighlightYellow").opacity(0.5), radius: 20)
                }
                .frame(height: 200)
                .opacity(animateElements ? 1 : 0)
                .scaleEffect(animateElements ? 1 : 0.5)
                .rotation3DEffect(
                    .degrees(animateElements ? 0 : 10),
                    axis: (x: 1, y: 0, z: 0)
                )
                
                VStack(spacing: 20) {
                    Text("Crystal Pathways")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color("TextPrimary")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                    
                    Text("Master unique mind-bending crystal challenges")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .opacity(0.9)
                }
                .padding(.horizontal, 40)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 20)
                
                Spacer()
                    .frame(height: 100)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floatingOffset = -15
            }
        }
    }
}

// MARK: - Page 2: Features
struct OnboardingPage2: View {
    @Binding var animateElements: Bool
    
    let features = [
        ("bolt.fill", "Energy Flow", "Navigate through streams"),
        ("diamond.fill", "Crystal Memory", "Match glowing patterns"),
        ("waveform.path", "Pulse Sync", "Perfect timing challenge"),
        ("square.grid.3x3.fill", "Matrix Build", "Complete energy circuits")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)
                
                Text("Four Unique Challenges")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(animateElements ? 1 : 0)
                
                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureCard(
                            icon: feature.0,
                            title: feature.1,
                            description: feature.2,
                            index: index,
                            animateElements: animateElements
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 100)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let index: Int
    let animateElements: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("HighlightYellow"), Color("SoftOrange")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .opacity(animateElements ? 1 : 0)
        .offset(x: animateElements ? 0 : -50)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateElements)
    }
}

// MARK: - Page 3: Ready
struct OnboardingPage3: View {
    @Binding var animateElements: Bool
    @State private var particleOffsets: [CGSize] = Array(repeating: .zero, count: 8)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 80)
                
                // Animated center piece
                ZStack {
                    // Floating particles
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color("HighlightYellow"))
                            .frame(width: 8, height: 8)
                            .offset(particleOffsets[index])
                            .opacity(animateElements ? 0.6 : 0)
                    }
                    
                    // Center glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("AccentGreen").opacity(0.6),
                                    Color("HighlightYellow").opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 80, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AccentGreen"), Color("HighlightYellow")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color("AccentGreen").opacity(0.5), radius: 30)
                }
                .frame(height: 250)
                .opacity(animateElements ? 1 : 0)
                .scaleEffect(animateElements ? 1 : 0.3)
                
                VStack(spacing: 20) {
                    Text("Your Crystal Adventure")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Master all challenges and unlock cosmic achievements")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 40)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : 30)
                
                Spacer()
                    .frame(height: 100)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            // Animate particles in a circle
            for index in 0..<8 {
                let angle = Double(index) * .pi * 2 / 8
                let radius: CGFloat = 80
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                
                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.1)
                ) {
                    particleOffsets[index] = CGSize(width: x, height: y)
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
