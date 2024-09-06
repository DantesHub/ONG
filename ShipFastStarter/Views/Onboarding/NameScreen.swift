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
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("What's your first name?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(firstName.isEmpty ? "Dylan" : firstName)
                    .sfPro(type: .bold, size: .h1Big)
                    .foregroundColor(firstName.isEmpty ? .gray : .white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.0))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        isNameFocused = true
                    }
                
                Spacer()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.firstName = firstName
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")
                        mainVM.onboardingScreen = .lastName // Assuming .birthday is the next screen
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(firstName.isEmpty)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
        .overlay(
            TextField("", text: $firstName)
                .focused($isNameFocused)
                .opacity(0)
                .autocorrectionDisabled(true)
        )
    }
}

struct NameScreen_Previews: PreviewProvider {
    static var previews: some View {
        NameScreen()
            .environmentObject(MainViewModel())
    }
}
