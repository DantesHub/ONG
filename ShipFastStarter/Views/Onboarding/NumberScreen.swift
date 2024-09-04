//
//  NumberScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct NumberScreen: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isNextEnabled = false
    @State private var isVerifyEnabled = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(authVM.isVerificationCodeSent ? "Enter verification code" : "Enter your phone number")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if !authVM.isVerificationCodeSent {
                HStack {
                    Text("🇺🇸")
                        .frame(width: 30, height: 20)
                    
                    Text("+1")
                        .foregroundColor(.white)
                    
                    TextField("", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onChange(of: phoneNumber) { newValue in
                            validatePhoneNumber(newValue)
                        }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                
                Text("Remember - never sign up\nwith another person's phone number.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                Button(action: {
                    Analytics.shared.logActual(event: "NumberScreen: Tapped Next", parameters: ["":""])
                    let formattedNumber = "+1\(phoneNumber)"
                    withAnimation {
                        if let user = mainVM.currUser {
                            
                            authVM.verifyCode(code: "3333333", user: user)
                        }
//                        authVM.signInWithPhoneNumber(phoneNumber: formattedNumber)
                    }
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isNextEnabled ? Color.white : Color.gray)
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                }
                .disabled(!isNextEnabled)
            } else {
                TextField("", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .onChange(of: verificationCode) { newValue in
                        isVerifyEnabled = newValue.count == 6
                    }
                
                Button(action: {
                    if let user = mainVM.currUser {
                        authVM.verifyCode(code: verificationCode, user: user)
                    }
                }) {
                    Text("Verify")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isVerifyEnabled ? Color.white : Color.gray)
                        .foregroundColor(.orange)
                        .cornerRadius(10)
                }
                .disabled(!isVerifyEnabled)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.orange)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func validatePhoneNumber(_ number: String) {
        let filtered = number.filter { $0.isNumber }
        phoneNumber = filtered.prefix(10).string
        isNextEnabled = phoneNumber.count == 10
    }
}

extension StringProtocol {
    var string: String { String(self) }
}

struct NumberScreen_Previews: PreviewProvider {
    static var previews: some View {
        NumberScreen().environmentObject(AuthViewModel())
    }
}
