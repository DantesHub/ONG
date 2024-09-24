//
//  TutorialModal.swift
//  ONG
//
//  Created by Dante Kim on 9/23/24.
//

import Foundation
import SwiftUI

struct TutorialModal: View {
    @Binding var isPresented: Bool
    @State private var currentSlide: Int = 1
    @State private var totalSlides: Int = 3 // Adjust this based on the number of tutorial slides
    @State private var isFeed = false
    
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 20) {
                // Slide indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalSlides, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.black : Color.gray.opacity(0.5))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Tutorial content
                if isFeed {
                    
                } else {
                    Group {
                        switch currentSlide {
                        case 0:
                            firstSlideContent
                        case 1:
                            secondSlideContent
                        default:
                            EmptyView()
                        }
                    }

                }
                
                
                // Navigation buttons
                HStack {
//                    if currentSlide > 0 {
//                        SharedComponents.SecondaryButton(title: "Back", isTutorial: true) {
//                            currentSlide -= 1
//                            Analytics.shared.log(event: "TutorialModal: Tapped Back")
//                        }
//                    }
//                    
                    SharedComponents.PrimaryButton(title: currentSlide == totalSlides - 1 ? isFeed ? "see feed" : "Finish" : "next", isTutorial: true) {
                        if currentSlide < totalSlides - 1 {
                            currentSlide += 1
                            Analytics.shared.log(event: "TutorialModal: Tapped Next")
                        } else {
                            isPresented = false
                            Analytics.shared.log(event: "TutorialModal: Finished Tutorial")
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 32)
        }
        .presentationDetents([.height(450)])
    }
    
    var firstSlideContent: some View {
        VStack(spacing: 12) {
            Image(.dylan)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
            Text("welcome to ur feed.")
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("here you'll see your homies, classmates and other ppl from your school and what they got aura for!")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
    
    var secondSlideContent: some View {
        VStack(spacing: 24) {
            HStack(spacing: -12) {
                Text("👧🏼")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color("red"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.1), lineWidth: 8)
                    )
                    .cornerRadius(8)
                    .rotationEffect(.degrees(32))
                
                Text("👦🏼")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color("green"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                            .stroke(Color.black.opacity(0.1), lineWidth: 8)
                    )
                    .cornerRadius(8)
                    .rotationEffect(.degrees(32))
                
                Text("👧🏼")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color("blue"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                            .stroke(Color.black.opacity(0.1), lineWidth: 8)
                    )
                    .cornerRadius(8)
                    .rotationEffect(.degrees(32))
                
                Text("👦🏼")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color("lightPurple"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                            .stroke(Color.black.opacity(0.1), lineWidth: 8)
                    )
                    .cornerRadius(8)
                    .rotationEffect(.degrees(32))
            }
            Text("you'll also see\nthese icons")
                .sfPro(type: .bold, size: .h1)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top)
            Text("maybe they mean something.\nmaybe they don’t...")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
    
    var thirdSlideContent: some View {
        VStack(spacing: 20) {
            Text("connect with friends")
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("add friends, chat, and see what they're up to in real-time!")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    TutorialModal(isPresented: .constant(true))
        .frame(height: 450)
}
