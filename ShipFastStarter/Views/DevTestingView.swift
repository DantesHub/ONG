//
//  DevTestingView.swift
//  ONG
//
//  Created by Dante Kim on 9/13/24.
//

import SwiftUI
import FirebaseAuth

struct DevTestingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var objectIdToDelete: String = ""

    var body: some View {
        NavigationView {
            List {
                Button("Reset Cooldown") {
                    let sixHoursAgo = Date().addingTimeInterval(-6 * 60 * 60)
                    mainVM.currUser?.lastPollFinished = sixHoursAgo
                    if let user = mainVM.currUser {
                        pollVM.currentPollIndex = 0
                        Task {
                            await pollVM.fetchPolls(for: user)
                        }
                        pollVM.resetCooldown(user: user)
                        mainVM.currentPage = .poll
                    }
                }
                Button("switch highschool") {
                    UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
                    mainVM.onboardingScreen = .highschool
                    mainVM.currentPage = .onboarding
                }
                
                Button("Reset App State") {
                    if let user = mainVM.currUser {
                        Task {
                            do {
                                try await FirebaseService.shared.deleteDocument(collection: FirestoreCollections.users, documentId: user.id)

                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    // Delete all UserDefaults
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()
                    print("All UserDefaults have been deleted")
                    
                    resetAppState()

                }
                
                // New section for deleting an object
                Section(header: Text("Delete Object")) {
                    TextField("Enter object ID", text: $objectIdToDelete)
                    Button("Delete Object") {
                        deleteObject(withId: objectIdToDelete)
                    }
                }
            }
            .navigationTitle("Dev Testing")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func resetAppState() {
        // Reset all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Sign out of Firebase
        do {
            try Auth.auth().signOut()
            print("Successfully signed out of Firebase")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        // Reset MainViewModel state
        mainVM.currUser = nil
        mainVM.currentPage = .onboarding
        mainVM.onboardingScreen = .first
        
        // Reset PollViewModel state
        pollVM.resetState()
        
        // You might want to reset other ViewModels as well
        
        print("App state has been reset")
    }
    
    private func deleteObject(withId id: String) {
        Task {
            do {
                try await FirebaseService.shared.deleteDocument(collection: FirestoreCollections.users, documentId: id)
                print("Successfully deleted object with ID: \(id)")
                objectIdToDelete = "" // Clear the text field
            } catch {
                print("Error deleting object: \(error.localizedDescription)")
            }
        }
    }
}
#Preview {
    DevTestingView()
}
