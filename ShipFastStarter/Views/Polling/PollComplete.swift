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
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    ZStack {
                        Text("+500")
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
                    Spacer()
                   
                }
                Text("you just finished\nyour first poll!")
                    .sfPro(type: .bold, size: .h1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding()
                    .padding(.top)
                Spacer()
                SharedComponents.PrimaryButton(title: "continue") {
                    Analytics.shared.log(event: "PollCompleted: Tapped Continue")
                    pollVM.completedPoll = false
                }
                .padding(.vertical, 48)
                .padding(.horizontal, 24)
            }
        }.frame(maxWidth: .infinity, alignment: .center)
    }


}

struct PollComplete_Previews: PreviewProvider {
    static var previews: some View {
        PollComplete()
            .environmentObject(PollViewModel())
    }
}
