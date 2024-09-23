//
//  Onboarding.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import Foundation
import SwiftUI


struct OnboardingView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var pollVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var highschoolVM: HighSchoolViewModel
    @State private var currentProgressIndex: Int = 0
    
    let totalSteps = 10
    
    var body: some View {
       ZStack {
           if mainVM.onboardingScreen == .color {
               Color.white.edgesIgnoringSafeArea(.all)
           } else {
               Color.primaryBackground.edgesIgnoringSafeArea(.all)
           }
            VStack {
                if mainVM.onboardingScreen != .first  {
                    HStack(alignment: .center) {
                        if  mainVM.onboardingScreen != .birthday && mainVM.onboardingScreen != .uploadProfile {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .foregroundColor(mainVM.onboardingScreen == .color ? .black : Color.primaryForeground)
                                .onTapGesture {
                                    Analytics.shared.log(event: "Onboarding: tapped Back")
                                    withAnimation {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        goBack()
                                    }
                                }.padding(.leading)
                                .padding(.trailing, 4)
                        }
                 
                        HStack(spacing: 4) {
                            ForEach(0..<totalSteps, id: \.self) { index in
                                StoryProgressBar(isComplete: index < currentProgressIndex)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }.padding(.top)
                    .padding(.horizontal, 8)                  
                }
                
                switch mainVM.onboardingScreen {
                    case .first: OnboardingScreen()
                    case .age: BirthdayScreen()
                    case .gender: GenderScreen()
                    case .birthday: BirthdayScreen()
                    case .name: NameScreen()
                    case .number: NumberScreen()
                    case .contacts: ContactsScreen()
                    case .location: LocationScreen()
                    case .highschool: HighSchoolScreen()
                    case .grade: GradeScreen() 
                    case .lastName: LastNameScreen()
                    case .username: UsernameScreen()
                    case .color: ColorScreen()
                    case .uploadProfile: UploadProfileScreen()
                    case .notification: NotificationScreen() 
                    case .addFriends: PeopleScreen()
                    case .lockedHighschool: LockedHighschoolScreen()
                }
            }
       }.onChange(of: mainVM.onboardingScreen) { newValue in
           updateProgressIndex(for: newValue)
       }
    }
    
    func goBack() {
        switch mainVM.onboardingScreen {
            case .first:
                break // Do nothing if we're already at the first screen
            case .age:
                mainVM.onboardingScreen = .first
            case .gender:
                mainVM.onboardingScreen = .first
            case .birthday:
                mainVM.onboardingScreen = .gender
            case .name:
                mainVM.onboardingScreen = .grade
            case .number:
                if authVM.isVerificationCodeSent {
                    authVM.isVerificationCodeSent = false
                } else {
                    mainVM.onboardingScreen = .username
                }
            case .contacts:
                mainVM.onboardingScreen = .number
            case .location:
                mainVM.onboardingScreen = .gender
            case .grade:
                mainVM.onboardingScreen = .gender
            case .lastName:
                mainVM.onboardingScreen = .grade
            case .highschool:
                mainVM.onboardingScreen = .notification
            case .username:
                mainVM.onboardingScreen = .lastName
            case .color:
                mainVM.onboardingScreen = .highschool
            case .uploadProfile:
                mainVM.onboardingScreen = .username
            case .notification:
                mainVM.onboardingScreen = .uploadProfile
            case .addFriends:
                mainVM.onboardingScreen = .highschool
            case .lockedHighschool:
                mainVM.onboardingScreen = .highschool
        }
    }

    func updateProgressIndex(for screen: OnboardingScreenType) {
//        let screenOrder: [OnboardingScreenType] = [.first, .birthday, .location, .grade, .name, .lastName, .username]
//        .location,
        let screenOrder: [OnboardingScreenType] = [.first, .birthday,  .gender, .grade, .name,  .lastName, .username, .number, .uploadProfile, .notification, .highschool, .lockedHighschool, .addFriends, .notification, .color]
        if let index = screenOrder.firstIndex(of: screen) {
            currentProgressIndex = min(index, totalSteps)
        }
    }
}

enum OnboardingScreenType {
    case first
    case age
    case gender
    case birthday
    case name
    case number
    case contacts
    case location
    case highschool
    case grade
    case lastName
    case username
    case color
    case uploadProfile
    case notification
    case addFriends
    case lockedHighschool
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(6)
                
                Rectangle()
                    .foregroundColor(Color.red)
                    .cornerRadius(6)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width)
            }
        }
        .frame(height: 12) // Set your desired height here
    }
}

//extension UITableView {
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        backgroundColor = .black
//    }
//    
//}
