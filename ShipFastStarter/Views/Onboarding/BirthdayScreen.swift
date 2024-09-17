//
//  BirthdayScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct BirthdayScreen: View {

    @EnvironmentObject var mainVM: MainViewModel
    @State private var birthdate = Date()
    @State private var yearsOld = 0
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("How old are you?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                DatePicker("", selection: $birthdate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .background(Color.white)
                    .cornerRadius(16)
                    .stroke(color: .black, width: 3)
                    .padding(.horizontal)
//                    .primaryShadow()

                Spacer()

                Text("you are \(calculateAge()) years old")
                    .sfPro(type: .semibold, size: .h2)
                    .foregroundColor(.white)
                    .padding()
                
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        // Handle continue action
                        mainVM.currUser?.birthday = birthdate.toString()
                        print("Selected birthday: \(formattedDate)")
                        Analytics.shared.log(event: "BirthdayScreen: Tapped Continue")
                        mainVM.onboardingScreen = .location
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
    private func calculateAge() -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthdate, to: Date())
        return ageComponents.year ?? 0
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: birthdate)
    }
}

struct BirthdayScreen_Previews: PreviewProvider {
    static var previews: some View {
        BirthdayScreen()
    }
}

#Preview {
    BirthdayScreen()
}


