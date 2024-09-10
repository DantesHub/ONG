//
//  GenderScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI

struct GenderScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var selectedGender: Gender?
    
    enum Gender: String, CaseIterable {
        case male = "👦 boy"
        case female = "👧 girl"
        case other = "🧒 non-binary"
    }
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("What's your gender?")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 32) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        GenderButton(gender: gender, isSelected: selectedGender == gender) {
                            selectedGender = gender
                        }
                    }
                }
                .padding(.vertical, 32)
                
                Spacer()
                
            
            }
        }
    }
}

struct GenderButton: View {
    @EnvironmentObject var mainVM: MainViewModel
    let gender: GenderScreen.Gender
    let isSelected: Bool
    let action: () -> Void
    @State private var opacity: Double = 1

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.opacity = 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    self.opacity = 1
                    mainVM.currUser?.gender = String(gender.rawValue.dropFirst(2))
                    mainVM.onboardingScreen = .color
                }
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 5)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                
                HStack {
                    Spacer()
                    Text(gender.rawValue)
                        .foregroundColor(.black)
                        .sfPro(type: .bold, size: .h2)
                    Spacer()
               
                }.padding(.horizontal, 32)
            }
            .frame(height: 132)
            .scaleEffect(opacity == 1 ? 1 : 0.95)
            .opacity(opacity)
            .padding(.horizontal)
        }
        .primaryShadow()
        .animation(.easeInOut, value: isSelected)
    }
}

struct GenderScreen_Previews: PreviewProvider {
    static var previews: some View {
        GenderScreen()
            .environmentObject(MainViewModel())
    }
}

#Preview {
    GenderScreen()
}
