//
//  NameScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct LastNameScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var lastName: String = ""
    @FocusState private var isNameFocused: Bool
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("what's your\nlast name?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(lastName.isEmpty ? "Molina" : lastName)
                    .sfPro(type: .bold, size: .h1Big)
                    .foregroundColor(lastName.isEmpty ? .gray : .white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.0))
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
                        mainVM.currUser?.lastName = lastName
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")
                        if StringValidator.isValid(lastName) {
                            mainVM.onboardingScreen = .username // Assuming .birthday is the next screen
                        } else {
                            showError = true
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(lastName.isEmpty)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .overlay(
            TextField("", text: $lastName)
                .focused($isNameFocused)
                .opacity(0)
                .autocorrectionDisabled(true)
        )
    }
}

struct LastNameScreen_Previews: PreviewProvider {
    static var previews: some View {
        LastNameScreen()
            .environmentObject(MainViewModel())
    }
}
