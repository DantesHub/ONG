//
//  BirthdayScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI
import UIKit

struct BirthdayScreen: View {

    @EnvironmentObject var mainVM: MainViewModel
    @State private var birthdate = Date()
    @State private var yearsOld = 0
    @State private var errorString = ""
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("what's ur age?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                
                DatePicker("", selection: $birthdate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .foregroundColor(.black)
                    .background(Color.white)
                    .cornerRadius(16)
                    .stroke(color: .black, width: 3)
                    .padding(.horizontal)
                    .shadow(color: .black, radius: 0, y: 6)
//                    .primaryShadow()
                Spacer()

                Text("you are \(calculateAge()) years old")
                    .sfPro(type: .semibold, size: .h2)
                    .foregroundColor(.white)
                    .padding()
                
                if errorString != "" {
                    Text(errorString)
                        .sfPro(type: .semibold, size: .h2)
                        .foregroundColor(.red)
                }
        

                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        if yearsOld >= 13 {
                            mainVM.currUser?.birthday = birthdate.toString()
                            print("Selected birthday: \(formattedDate)")
                            Analytics.shared.log(event: "BirthdayScreen: Tapped Continue")
                            mainVM.onboardingScreen = .location
                        } else {
                            Analytics.shared.log(event: "BirthdayScreen: Tapped Continue")
                            errorString = "you must be 13+ to use ONG"
                        }
                   
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }.onAppear {
//            if let transparentView = datePicker.subviews.first {
//                for subview in transparentView.subviews {
//                    print(String(describing: subview)) // Log subview hierarchy
//                }
//            }
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



#Preview {
    BirthdayScreen()
        .environmentObject(MainViewModel())
}


