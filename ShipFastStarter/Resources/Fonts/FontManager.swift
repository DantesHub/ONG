//
//  FontManager.swift
//  FitCheck
//
//  Created by Dante Kim on 11/2/23.
//

import SwiftUI

struct FontManager {
    
    static func defaultFont(size: CGFloat) -> Font {
        return .system(size: size, weight: .regular, design: .rounded)
    }
    
    static func heading1(size: CGFloat = 24) -> Font {
        return .system(size: size, weight: .bold, design: .rounded)
    }
    
    static func body1(size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .medium, design: .rounded)
    }
    
    static func sfPro(type: SFProType, size: FontSize) -> Font {
        return .system(size: size.rawValue, weight: type.weight, design: .rounded)
    }
}

enum SFProType {
    case regular
    case medium
    case semibold
    case bold
    case light
    case heavy
    case black
    
    var weight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .light: return .light
        case .heavy: return .heavy
        case .black: return .black
        }
    }
}

enum FontSize: CGFloat {
    case h1Big = 42
    case h1 = 34
    case h1Small = 32
    case h2 = 24
    case h3 = 22
    case h3p1 = 20
    case p2 = 17
    case p3 = 14
    case p4 = 12
    case title = 48
    case huge = 56
    case titleHuge = 72
    case sticker = 104
    case logo = 128
}

extension View {
    
    func defaultFont(size: CGFloat) -> some View {
        self.font(FontManager.defaultFont(size: size))
    }
    
    func heading1() -> some View {
        self.font(FontManager.heading1())
    }
    
    func body1() -> some View {
        self.font(FontManager.body1())
    }
    
    func sfPro(type: SFProType, size: FontSize) -> some View {
        self.font(FontManager.sfPro(type: type, size: size))
    }
    
    // Add other custom modifiers as needed
}
