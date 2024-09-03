//
//  MainViewModel.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var currentPage: Page = .onboarding
    @Published var isPro = false
    @Published var showHalfOff = false 
    @Published var onboardingProgress: Double = 0.0
    @Published var onboardingScreen: OnboardingScreenType = .location
}

enum Page: String {
    case home = "Home"
    case onboarding = "Onboarding"
}
