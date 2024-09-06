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
    let grades = ["9", "10", "11", "12"]
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("What grade are you in?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ForEach(grades, id: \.self) { grade in
                        SharedComponents.PrimaryButton(
                            title: "Grade \(grade)",
                            action: {
                                selectedGrade = grade
                            }
                        )
                        .opacity(selectedGrade == grade ? 1.0 : 0.6)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Text("You selected grade \(selectedGrade)")
                    .sfPro(type: .semibold, size: .h2)
                    .foregroundColor(.white)
                    .padding()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.grade = selectedGrade
                        Analytics.shared.log(event: "GradeScreen: Tapped Continue")
//                        mainVM.onboardingScreen = .next // Replace with the appropriate next screen
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
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
