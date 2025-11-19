//
//  SettingsView.swift
//  cc90
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    @State private var showResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Statistics section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistics")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        StatRow(icon: "💎", label: "Total crystals collected", value: "\(progressStore.totalFeathers)")
                        StatRow(icon: "⭐️", label: "Total stars collected", value: "\(progressStore.totalLanterns)")
                        StatRow(icon: "✅", label: "Total paths completed", value: "\(progressStore.totalCrossingsCompleted)")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Best streaks section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Best Performance")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        GameStatRow(icon: "🎯", gameName: "Safe Passage", value: "\(progressStore.bestStreakGame1)")
                        GameStatRow(icon: "💡", gameName: "Memory Path", value: "Level \(progressStore.bestStreakGame2)")
                        GameStatRow(icon: "🎵", gameName: "Rhythm Steps", value: "\(progressStore.bestStreakGame3) perfect")
                        GameStatRow(icon: "🧩", gameName: "Road Builder", value: "Level \(progressStore.bestStreakGame4)")
                    }
                    .padding(.horizontal, 20)
                }
                
                // Progress section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Progress")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18))
                            
                            Text("Reset journey")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color("SoftOrange"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset Journey", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                progressStore.resetJourney()
            }
        } message: {
            Text("Are you sure you want to reset all your progress? This action cannot be undone.")
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 24))
                
                Text(label)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("HighlightYellow"))
        }
        .padding(16)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

struct GameStatRow: View {
    let icon: String
    let gameName: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 24))
                
                Text(gameName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color("TextPrimary"))
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("AccentGreen"))
        }
        .padding(16)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

