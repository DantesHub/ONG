//
//  NotificationScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/8/24.
//

import Foundation
import SwiftUI

struct NotificationScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isNotificationEnabled = false

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Enable Notifications")
               

        }
    }
}

#Preview {
    NotificationScreen()
        .environmentObject(MainViewModel())
        .environmentObject(AuthViewModel())
}
