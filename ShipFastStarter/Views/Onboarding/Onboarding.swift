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
    @EnvironmentObject var authVM: MainViewModel

    var body: some View {
       ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
                if mainVM.onboardingScreen != .first {
                    HStack {
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
                        ProgressView(value: mainVM.onboardingProgress)
                            .progressViewStyle(CustomProgressViewStyle())
                            .frame(height: 24)
                            .padding(.trailing)
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
       }
            
    }
    
    func goBack() {
        switch mainVM.onboardingScreen {
            case .first:
                mainVM.onboardingScreen = .age
            case .age:
                mainVM.onboardingScreen = .gender
            case .gender:
                mainVM.onboardingScreen = .birthday
            case .birthday:
                mainVM.onboardingScreen = .name
            case .name:
                mainVM.onboardingScreen = .number
            case .number:
                mainVM.onboardingScreen = .contacts
            case .contacts:
                mainVM.onboardingScreen = .first
            case .location:
                mainVM.onboardingScreen = .location
            case .grade:
                mainVM.onboardingScreen = .location
            case .lastName:
                mainVM.onboardingScreen = .first
            case .highschool:
                mainVM.onboardingScreen = .age
            case .username:
                mainVM.onboardingScreen = .lastName
        }
        return

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
