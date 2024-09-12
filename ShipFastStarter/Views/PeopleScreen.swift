//
//  PeopleScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import SwiftUI

struct FriendButton: View {
    @Binding var selectedFriends: [User]
    let user: User
    
    private var isSelected: Bool {
        selectedFriends.contains { $0.id == user.id }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ZStack {
                    if let url = URL(string: user.proPic), !user.proPic.isEmpty {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
              
         
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(1), lineWidth: 4)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )
                }
                .frame(width: 64, height: 64)
                .cornerRadius(16)
                .primaryShadow()
                .opacity(isSelected ? 1 : 0.5)
                .rotationEffect(.degrees(-8))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .font(Font.title.weight(.bold))
                        .frame(width: 32)
                        .foregroundColor(.brightGreen)
                        .padding(2)
                        .background(Circle()
                            .fill(.darkGreen)
                            .stroke(color: .darkGreen))
                        .cornerRadius(40)
                        .offset(x: 35, y: 30)
                }
            }
            
            Text("\(user.firstName)")
                .sfPro(type: .bold, size: .p2)
                .foregroundColor(.white)
                .padding(.top, 8)
        }
        .onTapGesture {
            withAnimation {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                if isSelected {
                    selectedFriends.removeAll { $0.id == user.id }
                } else {
                    selectedFriends.append(user)
                }
            }
       
        }
    }
}

struct PeopleScreen: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var selectedFriends: [User] = []
    
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
                Text("add friends")
                    .sfPro(type: .bold, size: .h1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                Text("here’s some people you may know. tap to select and unselect. tap next when done.")
                    .sfPro(type: .medium, size: .p2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 56)
                    .foregroundColor(Color.white)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(profileVM.peopleList, id: \.id) { user in
                            FriendButton(selectedFriends: $selectedFriends, user: user)
                        }
                    }
                    .padding(.vertical)
                }
                
                SharedComponents.PrimaryButton(title: "next") {
                    if let user = mainVM.currUser {
                        Task {
                            mainVM.currUser = await profileVM.addFriends(currUser: user, users: selectedFriends)
                        }
                    }
                }.padding(.horizontal, 32)
                .padding(.bottom)
                
                
            }
        }
        .navigationTitle("People")
    }
}

struct PeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        PeopleScreen()
            .environmentObject(ProfileViewModel())
            .environmentObject(MainViewModel())
    }
}
