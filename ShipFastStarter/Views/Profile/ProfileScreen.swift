//
//  ProfileScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import SwiftUI

struct ProfileScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Profile Screen")
            }
        }
    }
}
