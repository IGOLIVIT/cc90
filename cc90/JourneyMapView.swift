//
//  JourneyMapView.swift
//  cc90
//

import SwiftUI

struct JourneyMapView: View {
    @ObservedObject var progressStore: JourneyProgressStore
    @Environment(\.dismiss) var dismiss
    
    let milestones = [
        Milestone(threshold: 0, icon: "🏁", title: "Journey begins", description: "Start your adventure"),
        Milestone(threshold: 10, icon: "💎", title: "First crystals", description: "Collect 10 crystals"),
        Milestone(threshold: 25, icon: "⭐️", title: "Star collector", description: "Gather stars"),
        Milestone(threshold: 50, icon: "✨", title: "Halfway there", description: "50 paths completed"),
        Milestone(threshold: 100, icon: "🌟", title: "Bright path", description: "100 crystals collected"),
        Milestone(threshold: 200, icon: "🎯", title: "Expert navigator", description: "Master all challenges"),
        Milestone(threshold: 500, icon: "👑", title: "Legendary traveler", description: "500 crystals collected")
    ]
    
    struct Milestone: Identifiable {
        let id = UUID()
        let threshold: Int
        let icon: String
        let title: String
        let description: String
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header summary
                VStack(spacing: 16) {
                    Text("Your Journey")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    
                    HStack(spacing: 20) {
                        StatBadge(icon: "💎", value: "\(progressStore.totalFeathers)", label: "Crystals")
                        StatBadge(icon: "⭐️", value: "\(progressStore.totalLanterns)", label: "Stars")
                        StatBadge(icon: "✅", value: "\(progressStore.totalCrossingsCompleted)", label: "Complete")
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Milestones road
                VStack(spacing: 0) {
                    ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                        let isReached = progressStore.totalFeathers >= milestone.threshold
                        
                        VStack(spacing: 0) {
                            // Milestone node
                            HStack(spacing: 16) {
                                // Icon circle
                                ZStack {
                                    Circle()
                                        .fill(isReached ? Color("AccentGreen") : Color("SecondaryBackground"))
                                        .frame(width: 70, height: 70)
                                    
                                    Text(milestone.icon)
                                        .font(.system(size: 32))
                                        .opacity(isReached ? 1.0 : 0.4)
                                }
                                
                                // Text
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(milestone.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(isReached ? Color("TextPrimary") : Color("TextSecondary"))
                                    
                                    Text(milestone.description)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(Color("TextSecondary"))
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                if isReached {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AccentGreen"))
                                        .font(.system(size: 24))
                                }
                            }
                            .padding(16)
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(16)
                            
                            // Connecting road segment
                            if index < milestones.count - 1 {
                                Rectangle()
                                    .fill(isReached ? Color("AccentGreen").opacity(0.5) : Color("TextSecondary").opacity(0.2))
                                    .frame(width: 4, height: 40)
                                    .padding(.leading, 35)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Motivational message
                VStack(spacing: 12) {
                    let nextMilestone = milestones.first { progressStore.totalFeathers < $0.threshold }
                    
                    if let next = nextMilestone {
                        Text("Next milestone:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("TextSecondary"))
                        
                        Text(next.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("HighlightYellow"))
                        
                        Text("\(next.threshold - progressStore.totalFeathers) crystals to go")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextSecondary"))
                    } else {
                        Text("🎉 All milestones reached! 🎉")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color("AccentGreen"))
                        
                        Text("You've mastered the journey!")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
                    .frame(height: 40)
            }
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .navigationTitle("Journey Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
            
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

