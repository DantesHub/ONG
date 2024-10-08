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
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var inboxVM: InboxViewModel
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @FocusState private var isPhoneNumberFocused: Bool
    @FocusState private var isVerificationCodeFocused: Bool
    @State private var showError = false
    @State private var isLoading = false
    @State private var isVerifying = false
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
        
                Text(authVM.isVerificationCodeSent ? "Enter verification\ncode" : "What's your phone\nnumber?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(height: 120)
                if !authVM.isVerificationCodeSent {
                    HStack {
                        Text("🇺🇸 +1")
                            .sfPro(type: .semibold, size: .h1)
                            .foregroundColor(.white)
                        
                        Text(phoneNumber.isEmpty ? "777-777-7777" : phoneNumber)
                            .sfPro(type: .semibold, size: .h1)
                            .foregroundColor(phoneNumber.isEmpty ? .gray : .white)
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .onTapGesture {
                        isPhoneNumberFocused = true
                    }
                    
                    if showError {
                        Text("Invalid phone number")
                            .sfPro(type: .semibold, size: .h3p1)
                            .foregroundColor(.red)
                    }
                    
                    Text("Remember - never sign up\nwith another person's phone number.")
                        .sfPro(type: .medium, size: .p2)
                        .multilineTextAlignment(.center)
                        .frame(height: 45)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                } else {
                    Text(verificationCode.isEmpty ? "Enter 6-digit code" : verificationCode)
                        .sfPro(type: .semibold, size: .h1)
                        .foregroundColor(verificationCode.isEmpty ? .gray : .white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isVerificationCodeFocused = true
                            }
                        }
//                    Text("sent to \(phoneNumber)")
                    if showError {
                        Text(authVM.errorString)
                            .sfPro(type: .semibold, size: .p2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 4) {
                        Text("didn't get a code?")
                            .sfPro(type: .medium, size: .p2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.white.opacity(0.6))
                        Text("resend")
                            .foregroundColor(.white)
                            .sfPro(type: .medium, size: .p2)
                            .multilineTextAlignment(.center)
                            .underline()
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    Analytics.shared.log(event: "NumberScreen: Tapped Resend")
                                    authVM.resendVerificationCode()
                                    sendVerificationCode()
                                }
                            }
                    }
                }
                
                Spacer()
                 
                SharedComponents.PrimaryButton(
                    title: authVM.isVerificationCodeSent ? "Verify" : "Next",
                    action: {
                        if !authVM.isVerificationCodeSent {
//                            verificationCode = "333333"
//                            verifyCode()
//                            mainVM.currUser?.fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
//                            let formattedNumber = "+1\(phoneNumber)"
//                            if var user = mainVM.currUser {
//                                mainVM.currUser?.number = formattedNumber
//                                user.number = formattedNumber
//                            }
                            //                            UserDefaults.standard.setValue(formattedNumber, forKey: "userNumber")

//                            UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
//                            if authVM.tappedLogin {
//                                Task {
//                                    isLoading = true
//                                    await mainVM.fetchUser()
//                                    if let user = mainVM.currUser, user.username != "naveedjohnmo" {
//                                        async let notifications = inboxVM.fetchNotifications(for: user)
//                                        async let peopleList = profileVM.fetchPeopleList(user: user)
//                                        async let profilePic = profileVM.fetchUserProfilePicture(user: user)
//                                        _ = await (notifications, peopleList, profilePic)
//                                        await pollVM.fetchPolls(for: user)
//                                        pollVM.entireSchool = profileVM.peopleList
//                                        mainVM.currentPage = .poll
//                                        authVM.tappedLogin = false
//                                        let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
//                                        do {
//                                            try await FirebaseService.shared.updateField(collection: "users", documentId: user.id, field: "fcmToken", value: fcmToken)
//                                        } catch {
//                                            print(error.localizedDescription)
//                                        }
//                                        isLoading = false
//                                    }
//                                }
//                            }
                            sendVerificationCode()
                        } else {
                            verifyCode()
                        
                        }
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .disabled(authVM.isVerificationCodeSent ? verificationCode.count != 6 : phoneNumber.count != 10)
                .opacity((!authVM.isVerificationCodeSent && phoneNumber.count != 10) || (authVM.isVerificationCodeSent && verificationCode.count != 6) ? 0.5 : 1)
            }
            .overlay(
                Group {
                    if !authVM.isVerificationCodeSent {
                        TextField("", text: $phoneNumber)
                            .focused($isPhoneNumberFocused)
                            .keyboardType(.numberPad)
                            .onChange(of: phoneNumber) {
                                validatePhoneNumber(phoneNumber)
                            }
                    } else {
                        TextField("", text: $verificationCode)
                            .focused($isVerificationCodeFocused)
                            .keyboardType(.numberPad)
                            .onChange(of: verificationCode) {
                                verificationCode = String(verificationCode.prefix(6))
                            }
                    }
                }
                .opacity(0)
            )
            .disabled(isLoading || isVerifying)
            
            if isLoading || isVerifying {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            isPhoneNumberFocused = true
        }
        .onDisappear {
            authVM.isVerificationCodeSent = false
        }
    }
    
    private func validatePhoneNumber(_ number: String) {
        let filtered = number.filter { $0.isNumber }
        phoneNumber = String(filtered.prefix(10))
        showError = false
    }
    
    private func sendVerificationCode() {
        Analytics.shared.logActual(event: "NumberScreen: Tapped Next", parameters: ["":""])
        let formattedNumber = "+1\(phoneNumber)"
        withAnimation {
            isLoading = true
            mainVM.currUser?.fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
            if var user = mainVM.currUser {
                mainVM.currUser?.number = formattedNumber
                user.number = formattedNumber
            }
            UserDefaults.standard.setValue(formattedNumber, forKey: "userNumber")
            authVM.signInWithPhoneNumber(phoneNumber: formattedNumber) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    if case .success = result {
                        isVerificationCodeFocused = true
                    }
                }
            }
        }
    }
    private func verifyCode() {
        isVerifying = true
        mainVM.currUser?.fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        if var user = mainVM.currUser {
            authVM.verifyCode(verificationCode: verificationCode) { result in
                DispatchQueue.main.async {
                    isVerifying = false
                    switch result {
                    case .success(let authResult):
                        if authVM.tappedLogin {
                            loginUser()
                        } else {
                            authVM.updateReferralCount()
                            FirebaseService.shared.addDocument(user, collection: "users") { str in
                                UserDefaults.standard.setValue(user.id, forKey: Constants.userId)
                                authVM.signInSuccessful = true
                                authVM.isVerified = true
                                withAnimation {
                                    mainVM.onboardingScreen = .uploadProfile
                                }
                                
                                print("Successfully verified and signed in: \(authResult.user.uid)")
                            }
                        }
                    case .failure(let error):
                        authVM.errorString = error.localizedDescription
                        showError = true
                        print("Error verifying code: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func loginUser() {
        Task {
            isLoading = true
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error)")
                } else {
                    print("Notification authorization granted: \(granted)")
                }
            }
            await mainVM.fetchUser()
            UserDefaults.standard.setValue(true, forKey: Constants.finishedFeedTutorial)
            UserDefaults.standard.setValue(true, forKey: Constants.finishedPollTutorial)
            UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
            if let user = mainVM.currUser, user.username != "naveedjohnmo" {
                async let notifications = inboxVM.fetchNotifications(for: user)
                async let peopleList = profileVM.fetchPeopleList(user: user)
                async let profilePic = profileVM.fetchUserProfilePicture(user: user)
                _ = await (notifications, peopleList, profilePic)
                let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
                do {
                    try await FirebaseService.shared.updateField(collection: "users", documentId: user.id, field: "fcmToken", value: fcmToken)
                } catch {
                    print(error.localizedDescription)
                }
                pollVM.entireSchool = profileVM.peopleList
                isLoading = false
                mainVM.currentPage = .poll
                authVM.tappedLogin = false
            }
        }
    }
}

struct NumberScreen_Previews: PreviewProvider {
    static var previews: some View {
        NumberScreen()
            .environmentObject(AuthViewModel())
            .environmentObject(MainViewModel())
    }
}
