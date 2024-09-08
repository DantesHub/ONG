//
//  OnboardingScreen.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI

struct OnboardingScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                HStack {
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
                    Spacer()
                   
                }
                Text("a social network for your high school.")
                    .sfPro(type: .bold, size: .h1Big)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top)
                Spacer()
                SharedComponents.PrimaryButton(title: "continue") {
                    mainVM.currUser = User.exUser
                    mainVM.onboardingScreen = .birthday
                }
                .padding(.vertical, 48)
                .padding(.horizontal, 24)
            }
        }.frame(maxWidth: .infinity, alignment: .center)
       
    }
}

#Preview {
    OnboardingScreen()
}

struct StrokedText: ViewModifier {
    let fillColor: Color
    let strokeColor: Color
    let strokeWidth: CGFloat

    func body(content: Content) -> some View {
        ZStack {
            content.foregroundColor(strokeColor)
            content.foregroundColor(fillColor)
                .offset(x: strokeWidth, y: strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: -strokeWidth, y: -strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: -strokeWidth, y: strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: strokeWidth, y: -strokeWidth)
        }
    }
}

extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}
