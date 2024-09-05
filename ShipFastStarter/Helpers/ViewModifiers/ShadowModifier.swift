//  ShadowViewModifier.swift
//  Doxo
//
//  Created by Dante Kim on 6/12/21.
//

import SwiftUI

struct ShadowViewModifier: ViewModifier {
    var darkMode: Bool = false
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    func body(content: Content) -> some View {
        content
            .drawingGroup()
            .shadow(color: Color.black, radius: 0, x: 0, y: 6)
    }
}


extension View {
    /// Adds a shadow onto this view with the specified `ShadowStyle`
    func primaryShadow(darkMode: Bool = false) -> some View {
        modifier(ShadowViewModifier(darkMode: darkMode))
    }
}


struct SpecificCornerViewModifier: ViewModifier {
    var size: CGSize
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: topLeft)
                    .frame(width: topLeft * 2, height: topLeft * 2)
                    .position(CGPoint(x: topLeft, y: topLeft))
            )
            .overlay(
                RoundedRectangle(cornerRadius: topRight)
                    .frame(width: topRight * 2, height: topRight * 2)
                    .position(CGPoint(x: size.width - topRight, y: topRight))
            )
            .overlay(
                RoundedRectangle(cornerRadius: bottomLeft)
                    .frame(width: bottomLeft * 2, height: bottomLeft * 2)
                    .position(CGPoint(x: bottomLeft, y: size.height - bottomLeft))
            )
            .overlay(
                RoundedRectangle(cornerRadius: bottomRight)
                    .frame(width: bottomRight * 2, height: bottomRight * 2)
                    .position(CGPoint(x: size.width - bottomRight, y: size.height - bottomRight))
            )
            .mask(content)
    }
}

extension View {
    func specificCornerRadius(size: CGSize, topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) -> some View {
        modifier(SpecificCornerViewModifier(size: size, topLeft: topLeft, topRight: topRight, bottomLeft: bottomLeft, bottomRight: bottomRight))
    }
}

struct ButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        .padding(1) // This creates the inner stroke effect
                        .mask(RoundedRectangle(cornerRadius: 11)) // Slightly smaller to fit inside
                }
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        modifier(ButtonStyleModifier())
    }
}
