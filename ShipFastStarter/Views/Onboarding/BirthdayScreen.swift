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
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("what's ur birthday")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()
                
                CustomDatePicker(date: $birthdate)
                         .frame(height: 200)  // Adjust the height as needed
                         .background(Color.white)
//                   .cornerRadius(16)
//                   .stroke(color: .black, width: 3)
//                   .padding(.horizontal)
                
                Spacer()

                Text("you are \(calculateAge()) years old")
                    .sfPro(type: .semibold, size: .h2)
                    .foregroundColor(.white)
                    .padding()
                
                SharedComponents.PrimaryButton(
                    title: "Continue",
                    action: {
                        mainVM.currUser?.birthday = birthdate.toString()
                        print("Selected birthday: \(formattedDate)")
                        Analytics.shared.log(event: "BirthdayScreen: Tapped Continue")
                        mainVM.onboardingScreen = .location
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
import SwiftUI


struct CustomDatePicker: UIViewRepresentable {
    @Binding var date: Date

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date

        // Customize appearance
        if let subview = uiView.subviews.first?.subviews.first?.subviews.first {
            subview.alpha = 0.0
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CustomDatePicker

        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}
