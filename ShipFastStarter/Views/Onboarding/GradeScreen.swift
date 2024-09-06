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
    let grades = ["freshman 🙈", "sophomore 🤔 ", "junior 😇", "senior 👑 "]
    
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
                    ForEach(grades, id: \.self) { grade in
                        SharedComponents.PrimaryButton(
                            title: "\(grade)",
                            isOption: true,
                            action: {
                                Analytics.shared.logActual(event: "GradeScreen: Tapped Continue", parameters: ["grade": grade])
                                mainVM.onboardingScreen = .name
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top)
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
