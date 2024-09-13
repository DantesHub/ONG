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
                
                DatePickerWrapper(date: $birthdate)
                    .frame(height: 220)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .padding(.horizontal)
                
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

struct DatePickerWrapper: UIViewRepresentable {
    @Binding var date: Date
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.backgroundColor = .clear
        picker.setValue(UIColor.black, forKeyPath: "textColor")
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = date
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: DatePickerWrapper
        
        init(_ parent: DatePickerWrapper) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.date = sender.date
        }
    }
}

#Preview {
    BirthdayScreen()
        .environmentObject(MainViewModel())
}
