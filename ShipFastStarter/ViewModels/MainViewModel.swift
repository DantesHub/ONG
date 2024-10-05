//
//  MainViewModel.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation

class MainViewModel: ObservableObject {
    @Published var currentPage: Page = .splash
    @Published var onboardingScreen: OnboardingScreenType = .first
    @Published var isPro = false
    @Published var showHalfOff = false 
    @Published var onboardingProgress: Double = 0.0
    @Published var currUser: User? 
    
    init() {
        
    }    
    
    func fetchUser() async {
        if let number = UserDefaults.standard.string(forKey: "userNumber") {
            do {
                let users: [User] = try await FirebaseService.getFilteredDocuments(collection: FirestoreCollections.users, filterField: "number", filterValue: number)
                if let user = users.first {
                    await MainActor.run {
                        self.currUser = user
                        print("successfully fetched user", user.id, user.firstName)
                    }
                } else {
                    print("No user found with the given phone number")
                }
            } catch {
                print("Error fetching user: \(error.localizedDescription)")
            }
        } else {
            await MainActor.run {
                self.currUser = User.exUser
            }
        }
    }
    
    func fetchUserById(_ userId: String) async {
        do {
            let user: User = try await FirebaseService.shared.getDocument(collection: FirestoreCollections.users, documentId: userId)
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
    
    
    func updateCurrentUser(_ updatedUser: User) {
        DispatchQueue.main.async {
            self.currUser = updatedUser
        }
    }
}

enum Page: String {
    case home = "Home"
    case onboarding = "Onboarding"
    case poll = "Polls"
    case cooldown = "Cooldown"
    case inbox = "Inbox"
    case profile = "Profile"
    case feed = "Feed"
    case splash = "Splash"
    case friendRequests = "FriendRequests"
}
