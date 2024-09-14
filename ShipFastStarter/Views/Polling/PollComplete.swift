//
//  PollComplete.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftUI

struct PollComplete: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var pollVM: PollViewModel
    @State private var showAuraPopup = false
    @State private var auraScale: CGFloat = 0.5
    @State private var auraOpacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                if showAuraPopup {
                HStack {
             
                        Spacer()
                        ZStack {
                            Text("+300")
                                .sfPro(type: .black, size: .sticker)
                                .frame(maxWidth: .infinity)
                                .rotationEffect(.degrees(-12))
                                .foregroundColor(.white)
                                .stroke(color: .black, width: 6)
                            Text("aura")
                                .sfPro(type: .black, size: .h1Big)
                                .frame(maxWidth: .infinity)
                                .rotationEffect(.degrees(-12))
                                .foregroundColor(.white)
                                .stroke(color: .red, width: 3)
                                .offset(x: 32, y: 36)
                                .shadow(color: .blue, radius: 1, y: 3)
                        }
                        .scaleEffect(auraScale)
                        .opacity(auraOpacity)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5), value: auraScale)
                        .animation(.easeInOut(duration: 0.5), value: auraOpacity)
                        Spacer()
               
                    }
                    
                    Text("aura\n finisher bonus!")
                        .sfPro(type: .bold, size: .h1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding()
                        .padding(.top)
                        .scaleEffect(auraScale)
                        .opacity(auraOpacity)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5), value: auraScale)
                        .animation(.easeInOut(duration: 0.5), value: auraOpacity)
                }
    
                Spacer()
                if showAuraPopup {
                    
                    VStack(spacing: 16) {
                        SharedComponents.PrimaryButton(title: "continue") {
                            Analytics.shared.log(event: "PollCompleted: Tapped Continue")
                            pollVM.completedPoll = false
                        }
                        .scaleEffect(auraScale)
                        .opacity(auraOpacity)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5), value: auraScale)
                        .animation(.easeInOut(duration: 0.5), value: auraOpacity)
                    }        .padding(.vertical, 48)
                        .padding(.horizontal, 24)
                }
//                    SharedComponents.PrimaryButton(title: "Skip the wait!") {
//                        Analytics.shared.log(event: "PollCompleted: Skipped Wait")
////                        if let user = mainVM.currUser {
////                            pollVM.resetCooldown(user: user)
////                        }
//                        presentationMode.wrappedValue.dismiss()
//                    }
                }
        
            
            
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.showAuraPopup = true
                self.auraScale = 0.01
                self.auraOpacity = 1
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        self.auraScale = 1.25
                    }
                }
            }
        }
    }
}

struct PollComplete_Previews: PreviewProvider {
    static var previews: some View {
        PollComplete()
//            .environmentObject(PollViewModel())
    }
}
