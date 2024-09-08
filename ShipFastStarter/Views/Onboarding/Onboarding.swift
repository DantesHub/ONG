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
    @State private var currentProgressIndex: Int = 0
    
    let totalSteps = 8
    
    var body: some View {
       ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
                if mainVM.onboardingScreen != .first  {
                    HStack(alignment: .center) {
                        if  mainVM.onboardingScreen != .birthday {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                                .foregroundColor(Color.primaryForeground)
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
                    case .number: 
                        NumberScreen()
                        .environmentObject(authVM)
                        .environmentObject(mainVM)
                    case .contacts: ContactsScreen()
                    case .location: LocationScreen()
                    case .highschool: HighSchoolScreen()
                    case .grade: GradeScreen() 
                    case .lastName: LastNameScreen()
                    case .username: UsernameScreen() 
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
                mainVM.onboardingScreen = .age
            case .birthday:
                mainVM.onboardingScreen = .gender
            case .name:
                mainVM.onboardingScreen = .birthday
            case .number:
                mainVM.onboardingScreen = .name
            case .contacts:
                mainVM.onboardingScreen = .number
            case .location:
                mainVM.onboardingScreen = .contacts
            case .grade:
                mainVM.onboardingScreen = .birthday
            case .lastName:
                mainVM.onboardingScreen = .birthday
            case .highschool:
                mainVM.onboardingScreen = .lastName
            case .username:
                mainVM.onboardingScreen = .highschool
        }
    }

    func updateProgressIndex(for screen: OnboardingScreenType) {
        let screenOrder: [OnboardingScreenType] = [.first, .birthday, .location, .grade, .name, .lastName, .username]
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

extension UITableView {
    open override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .black
    }
}
