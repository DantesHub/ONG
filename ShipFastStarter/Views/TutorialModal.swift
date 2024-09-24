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
    @State private var currentSlide: Int = 0
    @State private var totalSlides: Int = 5 // Adjust this based on the number of tutorial slides
    var isFeed = false
    
    
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
                } else {
                    Group {
                        switch currentSlide {
                        case 0:
                            onboardingSlideOne
                        case 1:
                            onboardingSlideTwo
                        case 2:
                            onboardingSlideThree
                        case 3:
                            onboardingSlideFour
                        case 4:
                            onboardingSlideFive
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
                    SharedComponents.PrimaryButton(title: currentSlide == totalSlides - 1 ? isFeed ? "see feed" : isFeed ? "see ur feed" : "Finish" : "next", isTutorial: true) {
                        if currentSlide < totalSlides - 1 {
                            currentSlide += 1
                            Analytics.shared.log(event: "TutorialModal: Tapped Next")
                        } else {
                            if isFeed {
                                UserDefaults.standard.setValue(true, forKey: Constants.finishedFeedTutorial)
                            } else {
                                UserDefaults.standard.setValue(true, forKey: Constants.finishedPollTutorial)
                            }
                            Analytics.shared.log(event: "TutorialModal: Finished Tutorial")
                            isPresented.toggle()
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 32)
        }
        .presentationDetents([.height(450)])
        .onAppear {
            if isFeed {
                totalSlides = 2
            } else {
                totalSlides = 5
            }
        }
    }
    
    var onboardingSlideOne: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            Text("welcome to your\nfirst poll.")
                .multilineTextAlignment(.center)
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("let's go over a few key things\nso you have a good idea\nwhat's going on.")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    var onboardingSlideTwo: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .stroke(Color(.black), lineWidth: 2)
                        .padding(3)
                    Text("1")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .frame(width: 40, height: 40)
                .drawingGroup()
                .shadow(color: Color.black, radius: 0, x: 0, y: 3)
                .rotationEffect(.degrees(-12))
                Text("polls are created to spread positivity + good vibes")
                    .multilineTextAlignment(.leading)
                    .sfPro(type: .bold, size: .h3p1)
                    .foregroundColor(.black)
            }
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .stroke(Color(.black), lineWidth: 2)
                        .padding(3)
                    Text("2")
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                }
                .frame(width: 40, height: 40)
                .drawingGroup()
                .shadow(color: Color.black, radius: 0, x: 0, y: 3)
                .rotationEffect(.degrees(-12))
                Text("the options are populated randomly ")
                    .multilineTextAlignment(.leading)
                    .sfPro(type: .bold, size: .h3p1)
                    .foregroundColor(.black)
            }
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .stroke(Color(.black), lineWidth: 2)
                        .padding(3)
                    Text("3")
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                }
                .frame(width: 40, height: 40)
                .drawingGroup()
                .shadow(color: Color.black, radius: 0, x: 0, y: 3)
                .rotationEffect(.degrees(-12))
                Text("you earn 🍞 bread and \n🔮 aura for finishing polls!")
                    .multilineTextAlignment(.leading)
                    .sfPro(type: .bold, size: .h3p1)
                    .foregroundColor(.black)
            }
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .stroke(Color(.black), lineWidth: 2)
                        .padding(3)
                    Text("4")
                        .font(.system(size: 16))
                        .foregroundColor(.black)

                }
                .frame(width: 40, height: 40)
                .drawingGroup()
                .shadow(color: Color.black, radius: 0, x: 0, y: 3)
                .rotationEffect(.degrees(-12))
                Text("answers are anonymous")
                    .multilineTextAlignment(.leading)
                    .sfPro(type: .bold, size: .h3p1)
                    .foregroundColor(.black)
            }.padding(.bottom)
            
        }
    }
    
     
    var onboardingSlideFour: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 5)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                Image(systemName: "forward.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 42)
                    .foregroundColor(Color.black)
            }.frame(width: 72, height: 72)
                .primaryShadow()
                .rotationEffect(.degrees(-16))
                .padding(.bottom)
            Text("skip")
                .multilineTextAlignment(.center)
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("don't want to answer a question? just hit skip to go to the next question. can't go back to it tho!")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }

    
    var onboardingSlideThree: some View {
        VStack(alignment: .center, spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 5)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                Image(systemName: "shuffle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 42)
                    .foregroundColor(Color.black)
            }.frame(width: 72, height: 72)
                .primaryShadow()
                .rotationEffect(.degrees(-16))
                .padding(.bottom)
            Text("shuffle")
                .multilineTextAlignment(.center)
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("don't think any of the options fit? \nhit shuffle to get new ones. you can do this 2x for every question!")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
    
    
    var onboardingSlideFive: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Text("❤️")
                .multilineTextAlignment(.center)
                .sfPro(type: .bold, size: .title)
                .foregroundColor(.black)
            Text("have fun!")
                .multilineTextAlignment(.center)
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.black)
            Text("polls reset every 6 hours.\nspread good vibes & give ur\nhomies some aura.")
                .sfPro(type: .medium, size: .h3p1)
                .foregroundColor(.black.opacity(0.5))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }

    private func bubbleView(for index: Int) -> some View {
        ZStack {
            Circle()
                .fill(randomColor(for: index))
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
            Text(randomEmoji(for: index))
                .font(.system(size: 32))
        }
        .frame(width: 64, height: 64)
        .shadow(color: Color.black, radius: 0, x: 0, y: 2)
    }

    // Helper functions to generate random colors and emojis
    private func randomColor(for index: Int) -> Color {
        let colors: [Color] = [.red, .green, .blue, Color("lightPurple")]
        return colors[index % colors.count]
    }

    private func randomEmoji(for index: Int) -> String {
        let emojis = ["👦", "👧", "👨", "👩"]
        return emojis[index % emojis.count]
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
                    .rotationEffect(.degrees(24))
                
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
                    .rotationEffect(.degrees(24))
                
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
                    .rotationEffect(.degrees(24))
                
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
                    .rotationEffect(.degrees(24))
            }
            Text("you'll also see\nthese icons")
                .sfPro(type: .bold, size: .h1)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .padding(.top)
            Text("maybe they mean something.\nmaybe they don't...")
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
