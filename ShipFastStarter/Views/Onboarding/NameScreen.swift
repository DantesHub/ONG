//
//  NameScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct NameScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var firstName: String = ""
    @FocusState private var isNameFocused: Bool
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("What's your name?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(firstName.isEmpty ? "Type your name" : firstName)
                    .sfPro(type: .semibold, size: .h1)
                    .foregroundColor(firstName.isEmpty ? .gray : .white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        isNameFocused = true
                    }
                
                if showError {
                    Text("invalid name")
                        .sfPro(type: .semibold, size: .h3p1)
                        .foregroundColor(.red)
                }
            
                Spacer()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.firstName = firstName
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")
                        if StringValidator.isValid(firstName) {
                            mainVM.onboardingScreen = .lastName
                        } else {
                            // Handle invalid input
                            showError = true
                            print("Invalid input")
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(firstName.isEmpty)
            }
        }
        .onAppear {
                isNameFocused = true
            
        }
        .overlay(
            TextField("", text: $firstName)
                .focused($isNameFocused)
                .opacity(0)
                .autocorrectionDisabled(true)
        )
    }
}

struct StringValidator {
    static let curseWords = ["fuck", "shit", "ass", "bitch", "damn", "cunt", "dick", "piss", "bastard"]
    
    static func isValid(_ input: String) -> Bool {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum length
        guard trimmedInput.count >= 2 else { return false }
        
        // Check for maximum length
        guard trimmedInput.count <= 20 else { return false }
        
        // Check for special characters
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?=\\")
        guard trimmedInput.rangeOfCharacter(from: specialCharacters) == nil else { return false }
        
        // Check for curse words
        let lowercasedInput = trimmedInput.lowercased()
        for word in curseWords {
            if lowercasedInput.contains(word) {
                return false
            }
        }
        
        // Check if it's only numbers
        if Int(trimmedInput) != nil {
            return false
        }
        
        return true
    }
    
    static func isLastNameValid(_ input: String) -> Bool {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for minimum length
        guard trimmedInput.count >= 1 else { return false }
        
        // Check for maximum length
        guard trimmedInput.count <= 14 else { return false }
        // Check for special characters
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+{}[]|\"<>,.~`/:;?=\\")
        guard trimmedInput.rangeOfCharacter(from: specialCharacters) == nil else { return false }
        
        // Check for curse words
        let lowercasedInput = trimmedInput.lowercased()
        for word in curseWords {
            if lowercasedInput.contains(word) {
                return false
            }
        }
        
        // Check if it's only numbers
        if Int(trimmedInput) != nil {
            return false
        }
        
        return true
    }
    
    static func isUsernameValid(_ input: String) -> Bool {
        let usernameRegex = "^[a-zA-Z][a-zA-Z0-9$\\-_]{2,19}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        let isValid = usernamePredicate.evaluate(with: input)
        
        if isValid {
            let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check for minimum length
            guard trimmedInput.count >= 1 else { return false }
            
            // Check for maximum length
            guard trimmedInput.count <= 14 else { return false }
            
            // Check for curse words
            let lowercasedInput = trimmedInput.lowercased()
            for word in curseWords {
                if lowercasedInput.contains(word) {
                    return false
                }
            }
            
            // Check if it's only numbers
            if Int(trimmedInput) != nil {
                return false
            }
            
            return true
        } else {
            return false
        }
       
    }
}

struct NameScreen_Previews: PreviewProvider {
    static var previews: some View {
        NameScreen()
            .environmentObject(MainViewModel())
    }
}
