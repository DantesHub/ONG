//
//  SplashScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/5/24.
//
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
                Text("ONG")
                    .sfPro(type: .black, size: .logo)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(-12))
                    .stroke(color: .black, width: 11)
                
                Text("get ready to vote!")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
        }
    }
}


#Preview {
    SplashScreen()
}
