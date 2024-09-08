//
//  NameScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct UsernameScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var username: String = ""
    @FocusState private var isNameFocused: Bool
    @State private var showError = false

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("create a username")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text(username.isEmpty ? "lilbro" : username)
                    .sfPro(type: .bold, size: .h1Big)
                    .foregroundColor(username.isEmpty ? .gray : .white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.0))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        isNameFocused = true
                    }
                if showError {
                    Text("invalid username")
                        .sfPro(type: .semibold, size: .h3p1)
                        .foregroundColor(.red)
                }
                Spacer()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.lastName = username
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")
                        Task {
                            if await checkIfUsernameIsTaken() {
                                showError = false
                                mainVM.onboardingScreen = .number // Assuming .birthday is the next screen
                            } else {
                                showError = true
                            }
                        }
                      
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(username.isEmpty)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .overlay(
            TextField("", text: $username)
                .focused($isNameFocused)
                .opacity(0)
                .autocorrectionDisabled(true)
        )
    }
    
    func checkIfUsernameIsTaken() async -> Bool {
        if StringValidator.isUsernameValid(username) {
            do {
                     let isTaken = try await FirebaseService.shared.isUsernameTaken(username)
                     return !isTaken  // Return true if username is NOT taken
                 } catch {
                     print("Error checking username: \(error.localizedDescription)")
                     return false  // Assume username is taken in case of error
                 }
            
        } else {
            await MainActor.run {
                     showError = true
                return false
                 }
        }
        return false
    }
}

struct UsernameScreenScreen_Previews: PreviewProvider {
    static var previews: some View {
        UsernameScreen()
            .environmentObject(MainViewModel())
    }
}
