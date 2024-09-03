//
//  OnboardingScreen.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI

struct OnboardingScreen: View {
    var body: some View {
        VStack {
            HStack {
                Text("Welcome to ShipFast2")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingScreen()
}
