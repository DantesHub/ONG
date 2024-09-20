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
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }.onTapGesture {
                        withAnimation {
                          if let user = Auth.auth().currentUser {
                              do {
                                  try Auth.auth().signOut()
                                  // Delete all UserDefaults
                                   let domain = Bundle.main.bundleIdentifier!
                                   UserDefaults.standard.removePersistentDomain(forName: domain)
                                   UserDefaults.standard.synchronize()
                                   print("All UserDefaults have been deleted")
                                    showSettings = false
                                    mainVM.currentPage = .onboarding
                                  
                              } catch {
                                  
                              }                                                   
                          } else {
                            // mainVM.currentPage = .login
                          }
                        }
                    }
                }
            }.colorScheme(.light)
        }
    }
}

#Preview {
    SettingsScreen(showSettings: .constant(false))
        .environmentObject(MainViewModel())
}
