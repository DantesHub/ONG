//
//  ContentView.swift
//  test
//
//  Created by Gursewak Singh on 16/09/24.
//

import SwiftUI
import CoreData

struct TestContentView: View {
    @State private var birthdate = Date()
    @State private var yearsOld = 0
    var body: some View {
        ZStack {
//            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("How old are you?")
//                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Spacer()

                DatePicker("", selection: $birthdate, displayedComponents: .date)

                                   .datePickerStyle(WheelDatePickerStyle())
                                   .labelsHidden()
                                   .background(Color.white)
                                   .cornerRadius(16)
                                   .preferredColorScheme(.light) // Force light mode
//                                   .stroke(color: .black, width: 3)
                                   .padding(.horizontal)
//                                   .primaryShadow()
                Spacer()

                Text("you are \(calculateAge()) years old")
                    .foregroundColor(.white)
                    .padding()
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



private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    TestContentView()
}
