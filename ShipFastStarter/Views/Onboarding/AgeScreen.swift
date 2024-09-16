//
//  AgeScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/14/24.
//

import Foundation
import SwiftUI

struct AgeScreen: View {
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
                
//                CustomDatePicker(date: $birthdate)
//                         .frame(height: 200)  // Adjust the height as needed
//                         .background(Color.white)
//                   .cornerRadius(16)
//                   .stroke(color: .black, width: 3)
//                   .padding(.horizontal)
            }
        }
    }
}

struct AgeScreen_Previews: PreviewProvider {
    static var previews: some View {
        AgeScreen()
    }
}
