//
//  LockedHighschoolScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/11/24.
//

import SwiftUI

struct LockedHighschoolScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var highschoolVM: HighSchoolViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showShareSheet = false
    @State private var showPeopleSheet = false

    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
//                HStack {
//                    Image(systemName: "arrow.left")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 28)
//                        .foregroundColor(.white)
//                        .bold()
//                    Spacer()
//                }
//                .padding(.horizontal, 32)
                ZStack {
            
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(1), lineWidth: 5)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                            )
                        Image("bsLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    }
                    .frame(width: 180, height: 160)
                    .primaryShadow()
                    .rotationEffect(.degrees(-12))
                    
                    Text("🔒")
                        .sfPro(type: .bold, size: .h1)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.black)
                        )
                        .offset(x: -80, y: -80)
                        .rotationEffect(.degrees(-12))
                    VStack(spacing: -12) {
                        Text("\(12 - highschoolVM.totalKids) more")
                        Text("needed")
                        Text("to unlock")
                    }
                        .sfPro(type: .bold, size: .h2)
                        .multilineTextAlignment(.center)
                        .lineSpacing(-10)
                        .minimumScaleFactor(0.8) // Allow text to scale down to 80% if needed
                        .padding(.horizontal, 32)
                        .foregroundColor(Color.white)
                        .stroke(color: .black, width: 2)
                        .offset(x: 60, y: -90)
                        .rotationEffect(.degrees(9))
                }.padding(.bottom, 24)
                VStack(spacing: 8) {
                    Text("hey! your school is still locked.")
                        .sfPro(type: .bold, size: .h1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Text("earn bread, limited profile badges, aura for inviting ur friends to ong.")
                        .sfPro(type: .semibold, size: .h3p1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .foregroundColor(Color.white)
                }
                .frame(height: 140)
                VStack(spacing: -32) {
                    HStack(spacing: 0) {
                        StickerView(text: "🚀", rotation: 6)
                        VStack(spacing: -32) {
                            Text("first")
                                .sfPro(type: .bold, size: .title)
                                .stroke(color: .red, width: 3)
                            Text("10")
                                .sfPro(type: .bold, size: .title)
                                .stroke(color: .red, width: 3)
                        }
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(16))
                        .shadow(color: .black, radius: 0, x: 3, y: 3)
                        //                    Text("bff")
                        //                        .sfPro(type: .bold, size: .h2)
                        //                        .stroke(color: .red, width: 3)
                        //                        .foregroundColor(.white)
                        
                        StickerView(text: "🫰", rotation: 5)
                            .offset(x: -10, y: 10)
                        VStack(spacing: -4) {
                            Text("bff")
                                .sfPro(type: .bold, size: .h1)
                                .stroke(color: .orange, width: 3)
                            Text("🍞")
                                .sfPro(type: .bold, size: .h1Big)
                        }
                        .offset(x: -12)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-12))
                        .shadow(color: .black, radius: 0, x: 3, y: 3)
                        
                    }
                    HStack {
                        VStack(spacing: -36) {
                            Text("4x")
                                .sfPro(type: .bold, size: .h1Big)
                                .stroke(color: .purple, width: 3)
                            Text("aura")
                                .sfPro(type: .bold, size: .h1Big)
                                .stroke(color: .purple, width: 3)
                        }.foregroundColor(.white)
                            .rotationEffect(.degrees(-16))
                            .shadow(color: .black, radius: 0, x: 3, y: 3)
                        Text("og")
                            .foregroundColor(.white)
                            .sfPro(type: .bold, size: .titleHuge)
                            .stroke(color: .green, width: 3)
                            .rotationEffect(.degrees(-16))
                            .offset(y: -12)
                            .shadow(color: .black, radius: 0, x: 3, y: 3)
                        StickerView(text: "👑", rotation: -5)
                            .rotationEffect(.degrees(16))
                            .offset(y: -12)
                    }
                }.padding(.vertical)
                SharedComponents.PrimaryButton(title: "invite friends") {
                    Analytics.shared.log(event: "LockedHighschool: Tapped Invite")
                    showShareSheet.toggle()
                }
                .padding(.horizontal, 24)
                
                Text("check who's already on")
                    .sfPro(type: .bold, size: .h3p1)
                    .foregroundColor(.white)
                    .underline()
                    .padding(.top)
                    .padding(.bottom, 24)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            Task {
                                if let user = mainVM.currUser {
                                    try await profileVM.fetchPeopleList(user: user)
                                }
                            }
                            showPeopleSheet.toggle()
                        }
                    }
         
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppearAnalytics(event: "LockedHighschoolScreen: Screenload")
        .sheet(isPresented: $showShareSheet) {
            InviteFriendsModal()
                .environmentObject(mainVM)
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
        }.sheet(isPresented: $showPeopleSheet) {
            PeopleScreen()
                .environmentObject(profileVM)
                .environmentObject(mainVM)
        }.onAppear {
            UserDefaults.standard.setValue(true, forKey: "sawLockedHighschool")
        }
    }
}

struct LockedHighschoolScreen_Previews: PreviewProvider {
    static var previews: some View {
        LockedHighschoolScreen()
            .environmentObject(MainViewModel())
            .environmentObject(ProfileViewModel())
            .environmentObject(HighSchoolViewModel())
    }
}

struct StickerView: View {
    let text: String
    let rotation: Double
    
    var body: some View {
        Text(text)
            .font(.system(size: 72))
            .padding(12)
            .rotationEffect(.degrees(rotation))
            .shadow(color: .black, radius: 0, x: 3, y: 3)
    }
}

struct GradientTextWithStreak: View {
    let text: String
    
    var body: some View {
        ZStack {
            // Gradient text
            Text(text)
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.pink, .black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
  
            // Outline
            Text(text)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.clear)
                .background(
                    Text(text)
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .blur(radius: 2)
                )
        }
        .rotationEffect(Angle(degrees: -10))
    }
}
