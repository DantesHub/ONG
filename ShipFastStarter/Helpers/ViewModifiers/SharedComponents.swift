//
//  SharedComponents.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import Foundation
import SwiftUI

struct GrayPrimaryButton: View {
    var title: String
    var action: () -> Void
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray)
                .stroke(Color.black.opacity(0.3), lineWidth: 2)
                .shadow(color: Color.black.opacity(0.2), radius: 3)
                .frame(height: 50)
                .scaleEffect(opacity == 1 ? 1 : 0.95)
                .opacity(opacity)
            Text(title)
                .foregroundColor(.white)
                .sfPro(type: .medium, size: .h3p1)
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.opacity = 0.7
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring()) {
                    self.opacity = 1
                    self.action()
                }
            }
        }
    }
}

struct SharedComponents {
    static func mainButton(title: String, action: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius:  16)
                .fill(Color.white)
                .stroke(.black, lineWidth: 2)
                .shadow(color: Color.black.opacity(0.2), radius: 3)
//                .primaryShadow()
            Text(title)  
                .sfPro(type: .semibold, size: .h3p1)
                .foregroundColor(Color.white)
        }
        .frame(height: 56)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation {
                action()
            }
        }
    }
    
    static func linearGradient() -> some View {
        Rectangle()
             .foregroundColor(.clear)
             .frame(width: 339, height: 312)
             .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.21, green: 0.21, blue: 0.64), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.58, green: 0.48, blue: 0.87), location: 0.45),
                        Gradient.Stop(color: Color(red: 0.89, green: 0.89, blue: 0.93), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )                     )
             .cornerRadius(339)
             .blur(radius: 100)
             .offset(y: 100)
    }

    struct PrimaryButton: View {
        var img: Image?
        var title: String
        var isDisabled: Bool
        var isOption: Bool = false
        @State private var opacity: Double = 1
        var action: () -> Void
        
        init(img: Image? = nil, title: String = "Continue", action: @escaping () -> Void, isDisabled: Bool = false) {
             self.img = img
             self.title = title
             self.action = action
             self.isDisabled = isDisabled
         }
        
        var body: some View {
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.opacity = 0.7
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring()) {
                        self.opacity = 1
                        self.action()
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
                        Text(title)
                            .foregroundColor(.black)
                            .sfPro(type: .semibold, size: .h3p1)
                        Spacer()
                        if let img = img {
                            img
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                    }.padding(.horizontal, 32)
                }
                .frame(height: isOption ? 96 : 72)
                .scaleEffect(opacity == 1 ? 1 : 0.95)
                .opacity(opacity)
            }
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .primaryShadow()
        }
    }

    struct PrimaryButton_Previews: PreviewProvider {
        static var previews: some View {
            PrimaryButton( action: {})
                .padding()
        }
    }

}
