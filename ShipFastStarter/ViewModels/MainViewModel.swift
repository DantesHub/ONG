//
//  MainViewModel.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var currentPage: Page = .poll
    @Published var isPro = false
    @Published var showHalfOff = false 
    @Published var onboardingProgress: Double = 0.0
    @Published var onboardingScreen: OnboardingScreenType = .location
    @Published var currUser: User?
    
    init() {
        
    }    
    
    func fetchUser() async {
        if let number = UserDefaults.standard.string(forKey: "userNumber") {
            do {
                let users: [User] = try await FirebaseService.getFilteredDocuments(collection: "users", filterField: "number", filterValue: number)
                if let user = users.first {
                    DispatchQueue.main.async {
                        self.currUser = user
                    }
                } else {
                    print("No user found with the given phone number")
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        } else {
            self.currUser = User.exUser
        }
    }
    
    func fetchUserById(_ userId: String) async {
        do {
            let user: User = try await FirebaseService.getDocument(collection: "users", documentId: userId)
            DispatchQueue.main.async {
                self.currUser = user
            }
        } catch {
            print("Error fetching user by ID: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("Error domain: \(nsError.domain), code: \(nsError.code)")
                if let errorDescription = nsError.userInfo["NSLocalizedDescription"] as? String {
                    print("Error description: \(errorDescription)")
                }
            }
        }
    }
    
    func addVotedPoll(_ pollId: String) {
        self.currUser?.votedPolls.append(pollId)
    }
}

enum Page: String {
    case home = "Home"
    case onboarding = "Onboarding"
    case poll = "Polls"
    case cooldown = "Cooldown"
}
