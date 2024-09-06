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
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("what's your last name?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
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
                
                Spacer()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.lastName = username
                        Analytics.shared.log(event: "NameScreen: Tapped Continue")
                        mainVM.onboardingScreen = .username // Assuming .birthday is the next screen
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
}

struct UsernameScreenScreen_Previews: PreviewProvider {
    static var previews: some View {
        UsernameScreen()
            .environmentObject(MainViewModel())
    }
}
