//
//  SettingsScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/20/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SettingsScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @Binding var showSettings: Bool
    @State private var showDeleteAccountConfirmation = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Notifications")
                            .foregroundColor(.blue)
                        Spacer()
                    }.onTapGesture {
                        Analytics.shared.log(event: "SettingsScreen: Tapped Notifications")
                        withAnimation {
                            // Handle notifications action
                        }
                    }
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }.onTapGesture {
                        Analytics.shared.log(event: "SettingsScreen: Tapped Sign Out")
                        withAnimation {
                            signOut()
                        }
                    }
                    HStack {
                        Text("Delete Account")
                            .foregroundColor(.red)
                        Spacer()
                    }.onTapGesture {
                        Analytics.shared.log(event: "SettingsScreen: Tapped Delete Account")
                        showDeleteAccountConfirmation = true
                    }
                    if let currUser = mainVM.currUser {
                        Text(currUser.id)
                        HStack {
                            Text(currUser.schoolId)
                        }
                    }
                }
            }.colorScheme(.light)
        }
        .alert(isPresented: $showDeleteAccountConfirmation) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    Analytics.shared.log(event: "SettingsScreen: Confirmed Delete Account")
                    Task {
                        await deleteAccount()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func signOut() {
        if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
                clearUserDefaults()
                showSettings = false
                mainVM.currentPage = .onboarding
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteAccount() async {
        if let user = Auth.auth().currentUser {
            if let currUser = mainVM.currUser {
                do {
                    // Delete user from users collection
                    try await FirebaseService.shared.deleteDocument(collection: "users", documentId: currUser.id)
                    
                    // Remove user from all poll options
                    try await FirebaseService.shared.removeUserFromPollOptions(userId: currUser.id)
                    
                    // Delete the Firebase Auth user
                    try await user.delete()
                    
                    // Sign out and clear user defaults
                    signOut()
                    clearUserDefaults()
                    
                    // Update UI
                    await MainActor.run {
                        showSettings = false
                        mainVM.currentPage = .onboarding
                    }
                } catch {
                    print("Error deleting account: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print("All UserDefaults have been deleted")
    }
}

#Preview {
    SettingsScreen(showSettings: .constant(false))
        .environmentObject(MainViewModel())
}
