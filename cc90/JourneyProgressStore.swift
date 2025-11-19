//
//  JourneyProgressStore.swift
//  cc90
//

import Foundation
import SwiftUI
import Combine

class JourneyProgressStore: ObservableObject {
    @Published var totalFeathers: Int = 0
    @Published var totalLanterns: Int = 0
    @Published var totalCrossingsCompleted: Int = 0
    @Published var bestStreakGame1: Int = 0
    @Published var bestStreakGame2: Int = 0
    @Published var bestStreakGame3: Int = 0
    @Published var bestStreakGame4: Int = 0
    @Published var hasCompletedOnboarding: Bool = false
    
    private let defaults = UserDefaults.standard
    
    init() {
        loadFromUserDefaults()
    }
    
    func loadFromUserDefaults() {
        totalFeathers = defaults.integer(forKey: "totalFeathers")
        totalLanterns = defaults.integer(forKey: "totalLanterns")
        totalCrossingsCompleted = defaults.integer(forKey: "totalCrossingsCompleted")
        bestStreakGame1 = defaults.integer(forKey: "bestStreakGame1")
        bestStreakGame2 = defaults.integer(forKey: "bestStreakGame2")
        bestStreakGame3 = defaults.integer(forKey: "bestStreakGame3")
        bestStreakGame4 = defaults.integer(forKey: "bestStreakGame4")
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
    }
    
    func saveToUserDefaults() {
        defaults.set(totalFeathers, forKey: "totalFeathers")
        defaults.set(totalLanterns, forKey: "totalLanterns")
        defaults.set(totalCrossingsCompleted, forKey: "totalCrossingsCompleted")
        defaults.set(bestStreakGame1, forKey: "bestStreakGame1")
        defaults.set(bestStreakGame2, forKey: "bestStreakGame2")
        defaults.set(bestStreakGame3, forKey: "bestStreakGame3")
        defaults.set(bestStreakGame4, forKey: "bestStreakGame4")
        defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
    }
    
    func earnReward(feathers: Int, lanterns: Int) {
        totalFeathers += feathers
        totalLanterns += lanterns
        totalCrossingsCompleted += 1
        saveToUserDefaults()
    }
    
    func updateBestStreak(gameNumber: Int, streak: Int) {
        switch gameNumber {
        case 1:
            if streak > bestStreakGame1 {
                bestStreakGame1 = streak
            }
        case 2:
            if streak > bestStreakGame2 {
                bestStreakGame2 = streak
            }
        case 3:
            if streak > bestStreakGame3 {
                bestStreakGame3 = streak
            }
        case 4:
            if streak > bestStreakGame4 {
                bestStreakGame4 = streak
            }
        default:
            break
        }
        saveToUserDefaults()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveToUserDefaults()
    }
    
    func resetJourney() {
        totalFeathers = 0
        totalLanterns = 0
        totalCrossingsCompleted = 0
        bestStreakGame1 = 0
        bestStreakGame2 = 0
        bestStreakGame3 = 0
        bestStreakGame4 = 0
        saveToUserDefaults()
    }
}

