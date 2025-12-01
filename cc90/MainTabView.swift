//
//  MainTabView.swift
//  cc90
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Energy Flow
            NavigationView {
                RoadCrossingGameView(progressStore: progressStore)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Energy Flow", systemImage: "bolt.fill")
            }
            .tag(0)
            
            // Tab 2: Crystal Memory
            NavigationView {
                CrystalMemoryGameView(progressStore: progressStore)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Crystals", systemImage: "diamond.fill")
            }
            .tag(1)
            
            // Tab 3: Pulse Sync
            NavigationView {
                RhythmTapGameView(progressStore: progressStore)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Pulse Sync", systemImage: "waveform.path")
            }
            .tag(2)
            
            // Tab 4: Matrix Build
            NavigationView {
                PuzzleRoadGameView(progressStore: progressStore)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Matrix", systemImage: "square.grid.3x3.fill")
            }
            .tag(3)
            
            // Tab 5: Progress
            NavigationView {
                ProgressHubView(progressStore: progressStore)
            }
            .navigationViewStyle(.stack)
            .tabItem {
                Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(4)
        }
        .accentColor(Color("HighlightYellow"))
    }
}

// MARK: - Progress Hub View (replaces old MainHubView)
struct ProgressHubView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Your Journey")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text("Track your progress and achievements")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(.top, 20)
                
                // Summary cards
                HStack(spacing: 16) {
                    SummaryCard(icon: "💎", value: "\(progressStore.totalFeathers)", label: "Crystals")
                    SummaryCard(icon: "⭐️", value: "\(progressStore.totalLanterns)", label: "Stars")
                    SummaryCard(icon: "✅", value: "\(progressStore.totalCrossingsCompleted)", label: "Complete")
                }
                .padding(.horizontal, 20)
                
                // Best performances
                VStack(alignment: .leading, spacing: 16) {
                    Text("Best Performance")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        PerformanceRow(
                            icon: "bolt.fill",
                            title: "Energy Flow",
                            value: "\(progressStore.bestStreakGame1) runs",
                            color: Color("AccentGreen")
                        )
                        PerformanceRow(
                            icon: "diamond.fill",
                            title: "Crystal Memory",
                            value: "Level \(progressStore.bestStreakGame2)",
                            color: Color("HighlightYellow")
                        )
                        PerformanceRow(
                            icon: "waveform.path",
                            title: "Pulse Sync",
                            value: "\(progressStore.bestStreakGame3) perfect",
                            color: Color("SoftOrange")
                        )
                        PerformanceRow(
                            icon: "square.grid.3x3.fill",
                            title: "Matrix Build",
                            value: "Level \(progressStore.bestStreakGame4)",
                            color: Color("AccentGreen")
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Journey Map Link
                NavigationLink(destination: JourneyMapView(progressStore: progressStore)) {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 20))
                        
                        Text("View Journey Map")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color("TextPrimary"))
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color("AccentGreen").opacity(0.3), Color("HighlightYellow").opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                
                // Settings Link
                NavigationLink(destination: SettingsView(progressStore: progressStore)) {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                        
                        Text("Settings")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color("TextPrimary"))
                    .padding(20)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SummaryCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 28))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("SecondaryBackground"))
        .cornerRadius(16)
    }
}

struct PerformanceRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
                
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

