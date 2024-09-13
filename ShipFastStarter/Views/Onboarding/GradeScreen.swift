//
//  GradeScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/5/24.
//

import SwiftUI

struct GradeScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var selectedGrade: String = "9"
    let grades = ["freshmen 🙈", "sophomore 🤔", "junior 😇", "senior 👑"]
    let bsGrades = ["SF1 🙈", "SF2 🤔", "BS Team 😇", "Friends of BS 👑"]

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("What grade\nare you in?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                
                VStack(spacing: 24) {
                    ForEach(bsGrades, id: \.self) { grade in
                        SharedComponents.PrimaryButton(
                            title: "\(grade)",
                            isOption: true,
                            action: {
                                let newGrade = String(grade.dropLast(2))
                                Analytics.shared.logActual(event: "GradeScreen: Tapped Grade", parameters: ["grade":newGrade])
                                mainVM.currUser?.grade = newGrade
                                mainVM.onboardingScreen = .gender
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                Spacer()
            }
        }
    }
}

struct GradeScreen_Previews: PreviewProvider {
    static var previews: some View {
        GradeScreen()
            .environmentObject(MainViewModel())
    }
}
