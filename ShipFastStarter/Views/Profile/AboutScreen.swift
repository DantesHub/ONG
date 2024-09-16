//
//  AboutScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/14/24.
//

import SwiftUI

struct AboutScreen: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            ZStack {
                Color.primaryBackground.edgesIgnoringSafeArea(.all)
                ScrollView {

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                presentationMode.wrappedValue.dismiss()       
                            }
                            .foregroundColor(.white)
                        Spacer()
                    }.padding(.horizontal, 16)
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
                    Text("a social network for your high school.")
                        .sfPro(type: .bold, size: .h1Big)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()

                    sectionView(title: "What is ONG?", content: "ONG is a social app for complimenting your friends. Answer polls, earn aura, and find out what your friends really think about you!")
                    
                    sectionView(title: "How can I play?", content: "The core of ONG is an anonymous polling game where you can compliment your friends and classmates. You see people from your school in your polls. They see the same. Everyone can vote without revealing their identity.")
                    
                    sectionView(title: "What's the cost?", content: "ONG is free to use. We offer optional paid upgrades for extra features.")
                    
                    // ... Add more sections ...

                    sectionView(title: "✨ Aura", content: "The more polls you win, the more aura you gain! Earn aura by participating in polls and being a great friend. Use it to level up and boost your presence. Join the public aura leaderboard and battle against your friends and even other schools.")
                    
                    sectionView(title: "🍞 Bread", content: "Bread is ONG's in-app currency for purchasing special items, badges, app icons, and features. Collect it through daily logins, special events, and leveling up. Spend it on exclusive items and features in the shop.")
                    
                    faqSection()
                        .padding(.top, 32)
                    
                    sectionView(title: "Privacy & Safety", content: "We prioritize your safety: interact only with chosen friends, contacts, and classmates, no direct messaging on ONG, strict content moderation.")
                }
                .padding()
            }
        }
    }
    
    private func sectionView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .sfPro(type: .bold, size: .h2)
                .foregroundColor(.white)
            Text(content)
                .sfPro(type: .medium, size: .p2)
                .foregroundColor(.white)
        }.padding(.horizontal)
    }
    
    private func faqSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Frequently Asked Questions")
                .sfPro(type: .bold, size: .h2)
                .foregroundColor(.white)
            
            faqItem(question: "Can I see who voted for me?", answer: "By default, you'll see the voter's grade and gender. But you can upgrade to [premium] to see more details, like their color and the first letter of their name.")
            
            faqItem(question: "Why am I not in many polls?", answer: "Don't worry! If you haven't been in many polls recently, we'll show you more often. Invite more friends to increase your chances!")
            
            // ... Add more FAQ items ...
        }
        .padding(.horizontal)
    }
    
    private func faqItem(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(question)
                .sfPro(type: .bold, size: .p2)
                .foregroundColor(.white)
            Text(answer)
                .sfPro(type: .regular, size: .p2)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AboutScreen()
}
