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
                ZStack {
                    Text("ONG")
                        .sfPro(type: .black, size: .logo)
                        .frame(maxWidth: .infinity)
                        .rotationEffect(.degrees(-12))
                        .foregroundColor(.white)
                        .stroke(color: .black, width: 11)
                    Text("ONG")
                        .sfPro(type: .black, size: .logo)
                        .frame(maxWidth: .infinity)
                        .rotationEffect(.degrees(-12))
                        .foregroundColor(.white)
                        .stroke(color: .black, width: 11)
                        .offset(y: -4)
                }
                
                Text("Get ready to vote!")
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
