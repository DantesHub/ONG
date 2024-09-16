//
//  FriendsScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/14/24.
//

import Foundation
import SwiftUI

struct FriendsScreen: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var selectedFriends: Set<String> = []
    @State private var showShareSheet = false
    
    let columns = [
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24)
    ]
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                Spacer()
                if mainVM.onboardingScreen != .addFriends {
                    Text("ur homies")
                        .sfPro(type: .bold, size: .h1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                } else {
                    Text("add friends")
                        .sfPro(type: .bold, size: .h1)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                        .padding(.horizontal)
                    Text("here's some people you may know. tap to select and unselect. tap next when done.")
                        .sfPro(type: .medium, size: .p2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 56)
                        .foregroundColor(Color.white)
                }
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(profileVM.friends, id: \.id) { user in
                            FriendButton(
                                user: user,
                                isSelected: selectedFriends.contains(user.id),
                                onTap: {
                                    withAnimation {
                                        if selectedFriends.contains(user.id) {
                                            selectedFriends.remove(user.id)
                                        } else {
                                            selectedFriends.insert(user.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}
