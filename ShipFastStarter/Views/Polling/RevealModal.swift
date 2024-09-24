//
//  RevealModal.swift
//  ONG
//
//  Created by Dante Kim on 9/23/24.
//

import Foundation
import SwiftUI

struct RevealModal: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var inboxVM: InboxViewModel

    @State private var showGodDetailView = false
    @State private var showRevealDetailView = false
    @State private var notEnoughBread = false
    @State private var revealLetter = false
    @State private var revealFullName = false
    @State private var revealShield = false

  var body: some View {
      ZStack {
          Color.black.edgesIgnoringSafeArea(.all)
          VStack {
              Spacer()
              if !revealLetter && !revealShield {
                  if !(showGodDetailView || showRevealDetailView) {
                      Text("see who sent it")
                          .sfPro(type: .bold, size: .h1)
                          .foregroundColor(.white)
                          .frame(maxWidth: .infinity, alignment: .center)
                  }
              if !showRevealDetailView {
                  Spacer()
                  GeometryReader { geometry in
                      Spacer()
                      ZStack(alignment: .leading) {
                          RoundedRectangle(cornerRadius: 16)
                              .fill(Color.primaryBackground)
                              .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "00278D").opacity(0.7), lineWidth: 4)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                              )
                          VStack(spacing: 12) {
                              HStack {
                                  VStack(spacing: -28) {
                                      Text("god")
                                          .sfPro(type: .bold, size: .h1Big)
                                          .stroke(color: .black, width: 3)
                                      Text("mode")
                                          .sfPro(type: .bold, size: .h1Big)
                                          .stroke(color: .black, width: 3)
                                  }.foregroundColor(.white)
                                      .rotationEffect(.degrees(-16))
                                      .shadow(color: .black, radius: 0, x: 3, y: 3)
                                  
                                      .frame(maxWidth: .infinity, alignment: .center)
                              }
                              .padding(.horizontal, 32)
                              Text("🍞 40,000")
                                  .padding(4)
                                  .foregroundColor(.white)
                                  .sfPro(type: .semibold, size: .p3)
                                  .background(Capsule().fill(.black))
                          }
                      }
                      .drawingGroup()
                      .shadow(color: Color(hex: "00278D"), radius: 0, x: 0, y: 6)
                      .padding(.horizontal)
                      .onTapGesture {
                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
                          withAnimation {
                              Analytics.shared.log(event: "RevealModal: Tapped God Mode")
                              showGodDetailView = true
                          }
                      }
                      
                      Text("lasts 1 week")
                          .sfPro(type: .bold, size: .h3p1)
                          .foregroundColor(.white.opacity(0.8))
                          .opacity(0.7)
                          .offset(x: 245, y: 12)
                      ZStack {
                          Text("👀")
                              .font(.system(size: 48))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 16, y: 0)
                          Text("🧿")
                              .font(.system(size: 36))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 84, y: 32)
                          Text("🧿")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 72, y: 128)
                          Text("👀")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 32, y: 72)
                          Text("👀")
                              .font(.system(size: 48))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 242, y: 24)
                          Text("🧿")
                              .font(.system(size: 36))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 300, y: 32)
                          Text("🧿")
                              .font(.system(size: 32))
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 248, y: 128)
                          Text("👀")
                              .font(.system(size: 42))
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .shadow(color: .black, radius: 0, x: 3, y: 3)
                              .offset(x: 300, y: 84)
                      }.opacity(0.75)
                      
                  }
                  .frame(height: 204)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          Analytics.shared.log(event: "RevealModal: Tapped God Mode")
                          showGodDetailView.toggle()
                      }
                  }
              }
              if showGodDetailView {
                  VStack(spacing: 0) {
                      Text("Features")
                          .sfPro(type: .bold, size: .h2)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding([.top, .horizontal], 24)
                      VStack(alignment: .leading, spacing: -12) {
                          Text("· Unlimited first letter reveals")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· 2 full name reveals")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· 4 shields (no one can reveal you)")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· custom app icon")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                          Text("· custom profile frame")
                              .sfPro(type: .bold, size: .h3p1)
                              .padding(8)
                      }
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .padding(.horizontal, 24)
                  }.foregroundColor(.white)
                  if notEnoughBread {
                      Text("you don't have enough bread. you can more bread by doing more polls or")
                          .sfPro(type: .semibold, size: .p2)
                          .foregroundColor(.red)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .padding(.vertical, 4)
                      Text("buy more here")
                          .sfPro(type: .semibold, size: .h3p1)
                          .foregroundColor(.white)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .underline()
                          .onTapGesture {
                              Analytics.shared.log(event: "GodMode: Tapped Buy More")
                              UIImpactFeedbackGenerator(style: .light)
                              withAnimation {
                              
                              }
                          }
                  }
                  Spacer()
                  ZStack(alignment: .leading) {
                      RoundedRectangle(cornerRadius: 16)
                          .fill(Color.primaryBackground)
                          .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "00278D").opacity(0.7), lineWidth: 4)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                          )
                      HStack {
                          Text("activate god mode")
                              .sfPro(type: .bold, size: .h3p1)
                              .foregroundColor(.white)
                              .frame(maxWidth: .infinity, alignment: .center)
                      }
                      .padding(.horizontal, 32)
                  }
                  .drawingGroup()
                  .shadow(color: Color(hex: "00278D"), radius: 0, x: 0, y: 6)
                  .frame(height: 72)
                  .padding()
                  .opacity(notEnoughBread ? 0.5 : 1)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          Analytics.shared.log(event: "GodMode: Tapped Activate")
                          if let currUser = mainVM.currUser {
                              if currUser.bread < 5000 {
                                  Analytics.shared.log(event: "GodMode: Triggered Not Enough")
                                  notEnoughBread = true
                              } else {
                                  // unlock god mode
                              }
                          }
                      }
                  }
              }
              if !(showGodDetailView || showRevealDetailView) {
                  Text("---- or ----")
                      .sfPro(type: .bold, size: .h2)
                      .foregroundColor(.white.opacity(0.5))
                      .padding(.vertical)
              }
           
              if !showGodDetailView {
                  Spacer()
                  GeometryReader { geometry in
                      ZStack(alignment: .leading) {
                          RoundedRectangle(cornerRadius: 16)
                              .fill(Color.primaryRed)
                              .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.darkRed, lineWidth: 4)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                              )
                          VStack(spacing: 0) {
                              HStack {
                                  VStack(spacing: -20) {
                                      Text("reveal")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                      Text("first")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                      Text("letter")
                                          .sfPro(type: .bold, size: .h1)
                                          .stroke(color: .black, width: 3)
                                  }.foregroundColor(.white)
                                      .shadow(color: .black, radius: 0, x: 1, y: 1)
                                      .frame(maxWidth: .infinity, alignment: .center)
                              }
                              .padding(.horizontal, 32)
                              Text("🍞 5,000")
                                  .padding(4)
                                  .foregroundColor(.white)
                                  .sfPro(type: .semibold, size: .p3)
                                  .background(Capsule().fill(.black))
                          }
                          
                      }
                      .drawingGroup()
                      .shadow(color: Color.darkRed, radius: 0, x: 0, y: 6)
                      .padding(.horizontal)
                
                      ZStack {
                          // Existing letters
                          Text("A")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.5)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 16, y: 0)
                          Text("S")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black)
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .offset(x: 72, y: 32)
                          Text("J")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 72, y: 100)
                          Text("K")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.4)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 32, y: 64)
                          Text("B")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(12))
                              .offset(x: 242, y: 0)
                          Text("C")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(64))
                              .offset(x: 300, y: -12)
                          Text("N")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 312, y: 32)
                          Text("D")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(24))
                              .offset(x: 254, y: 48)
                          Text("P")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 2)
                              .padding(12)
                              .rotationEffect(.degrees(-16))
                              .offset(x: 248, y: 96)
                          Text("M")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(16))
                              .offset(x: 300, y: 84)
                          
                          // New letters
                          Text("E")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h3)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(-8))
                              .offset(x: 100, y: -10)
                          Text("F")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h2)
                              .stroke(color: .black, width: 1.2)
                              .padding(12)
                              .rotationEffect(.degrees(20))
                              .offset(x: 280, y: 120)
                          Text("G")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h1)
                              .stroke(color: .black, width: 1.5)
                              .padding(12)
                              .rotationEffect(.degrees(-12))
                              .offset(x: 20, y: 110)
                          Text("H")
                              .foregroundColor(Color.primaryRed)
                              .sfPro(type: .bold, size: .h3)
                              .stroke(color: .black, width: 1)
                              .padding(12)
                              .rotationEffect(.degrees(15))
                              .offset(x: 100, y: 80)
                          //                      Text("I")
                          //                          .foregroundColor(Color.primaryRed)
                          //                          .sfPro(type: .bold, size: .h2)
                          //                          .stroke(color: .black, width: 1.3)
                          //                          .padding(12)
                          //                          .rotationEffect(.degrees(-5))
                          //                          .offset(x: 160, y: -12)
                      }
                  }
                  .frame(height: 174)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          Analytics.shared.log(event: "RevealModal: Tapped Reveal Letter")
                          showRevealDetailView = true
                          
                      }
                  }
                  Spacer()
              }

              if showRevealDetailView {
                  VStack(spacing: 0) {
                      Text("unlocking this will give you the first letter of the person that gave u aura for this poll.")
                          .sfPro(type: .bold, size: .h2)
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding([.top, .horizontal], 24)
                          .multilineTextAlignment(.center)
                  }.foregroundColor(.white)
                  Spacer()
                  if notEnoughBread {
                      Text("you don't have enough bread. you can more bread by doing more polls or")
                          .sfPro(type: .semibold, size: .p2)
                          .foregroundColor(.red)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .padding(.vertical, 8)
                      Text("buy more here")
                          .sfPro(type: .semibold, size: .h3p1)
                          .foregroundColor(.white)
                          .multilineTextAlignment(.center)
                          .padding(.horizontal)
                          .underline()
                          .onTapGesture {
                              UIImpactFeedbackGenerator(style: .light).impactOccurred()
                              withAnimation {
                                  Analytics.shared.log(event: "RevealLetter: Tapped By More")
                              }
                          }
                  }
         
                  ZStack(alignment: .leading) {
                      RoundedRectangle(cornerRadius: 16)
                          .fill(Color.primaryRed)
                          .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.darkRed.opacity(0.7), lineWidth: 4)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                          )
                      HStack {
                          Text("reveal for 5000 🍞")
                              .sfPro(type: .bold, size: .h3p1)
                              .foregroundColor(.white)
                              .frame(maxWidth: .infinity, alignment: .center)
                      }
                      .padding(.horizontal, 32)
                  }
                  .drawingGroup()
                  .shadow(color: Color.darkRed, radius: 0, x: 0, y: 6)
                  .frame(height: 72)
                  .padding()
                  .opacity(notEnoughBread ? 0.5 : 1)
                  .onTapGesture {
                      UIImpactFeedbackGenerator(style: .light).impactOccurred()
                      withAnimation {
                          if let currUser = mainVM.currUser {
                              if currUser.bread < 5000 {
                                  notEnoughBread = true
                              } else {
                                  if inboxVM.selectedInbox?.shields ?? 0 > 0 {
                                      revealLetter = true
                                  } else {
                                      revealShield = true
                                  }
                              }
                          }
                      }
                  }
              }
              Spacer()
              } else {
                  if !(showGodDetailView || showRevealDetailView) {
                      Text(revealShield ? "we tried to reaveal them, but they had a shield on." : revealFullName ? "their name is..." : "the first letter of their name is...")
                          .sfPro(type: .bold, size: .h2)
                          .foregroundColor(.white)
                          .frame(maxWidth: .infinity, alignment: .center)
                          .multilineTextAlignment(.center)
                          .padding(.top)
                          .padding(.horizontal)
                  }
                  Spacer()
                  if revealShield {
                      Text("🛡️")
                          .sfPro(type: .bold, size: .logo)
                          .frame(maxWidth: .infinity)
                          .foregroundColor(Color.white.opacity(0.65))
                          .stroke(color: Color.primaryBackground, width: 6)
                          .offset(y: -4)
                  } else {
                      if revealFullName {
                          Text("dante")
                              .sfPro(type: .bold, size: .huge)
                              .frame(maxWidth: .infinity)
                              .rotationEffect(.degrees(-12))
                              .foregroundColor(Color.white.opacity(0.65))
                              .stroke(color: Color.darkPurple, width: 3)
                              .shadow(color: Color.darkPurple, radius: 0, x: 0, y: 3)
                              .offset(y: -4)
                      } else {
                          Text("A")
                              .sfPro(type: .bold, size: .logo)
                              .frame(maxWidth: .infinity)
                              .rotationEffect(.degrees(-12))
                              .foregroundColor(Color.white.opacity(0.65))
                              .stroke(color: Color.darkPurple, width: 6)
                              .shadow(color: Color.darkPurple, radius: 0, x: 0, y: 3)
                              .offset(y: -4)
                      }
                  }
                
               
                  Spacer()
                  if revealLetter {
                      ZStack(alignment: .leading) {
                          RoundedRectangle(cornerRadius: 16)
                              .fill(Color.primaryBackground)
                              .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "00278D").opacity(0.7), lineWidth: 4)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                              )
                          HStack {
                              Text("reveal full name (2 left)")
                                  .sfPro(type: .bold, size: .h3p1)
                                  .foregroundColor(.white)
                                  .frame(maxWidth: .infinity, alignment: .center)
                          }
                          .padding(.horizontal, 32)
                      }
                      .drawingGroup()
                      .shadow(color: Color(hex: "00278D"), radius: 0, x: 0, y: 6)
                      .frame(height: 64)
                      .padding()
                      .opacity(notEnoughBread ? 0.5 : 1)
                      .onTapGesture {
                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
                          withAnimation {
                              Analytics.shared.log(event: "GodMode: Tapped Activate")
                              if let currUser = mainVM.currUser {
                                  if currUser.bread < 5000 {
                                      Analytics.shared.log(event: "GodMode: Triggered Not Enough")
                                      notEnoughBread = true
                                  } else {
                                      // unlock god mode
                                  }
                              }
                          }
                      }.padding(.bottom)
                  }
       

              }
          }
      }
      .presentationDetents([.height(revealShield ? 300 : revealLetter ? 400 : !(showGodDetailView || showRevealDetailView) ? 600 : showGodDetailView ? 675 : 600)])
      .presentationDragIndicator(.visible)

  }
}

#Preview {
    ZStack {
        Color.white
        RevealModal()
            .environmentObject(InboxViewModel())
            .environmentObject(MainViewModel())
            .frame(height: 450)
    }
}
