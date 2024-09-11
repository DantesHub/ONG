//
//  PeopleScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import SwiftUI

struct PushableButton: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    
    @Binding var title: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.isPressed = false
                    self.action()
                }
            }
        }) {
            Text(title)
                .sfPro(type: .bold, size: .p3)
                .foregroundColor(Color.blue)
                .frame(width: 96, height: 32)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.white)
                        Capsule()
                            .stroke(Color.black, lineWidth: 2)
                            .cornerRadius(16)
                    }
                )
                .offset(y: isPressed ? 4 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .drawingGroup()
        .shadow(color: Color.black, radius: 0, x: 0, y: isPressed ? 1 : 5)
    }
}

struct FriendRow: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var status: String = ""
    let user: User
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.2), lineWidth: 2)
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                
                if !user.proPic.isEmpty {
                                CachedAsyncImage(url: URL(string: user.proPic)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    case .failure:
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.gray)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            }
        }
            .padding(.bottom)
            .rotationEffect(.degrees(-12))
            
            HStack {
                Text("\(user.firstName) \(user.lastName)")
                    .sfPro(type: .medium, size: .h3p1)
                    .foregroundColor(Color.black)
                    .padding(.leading)
                Spacer()
                PushableButton(title: $status) {
                    if let currUser = mainVM.currUser {
                        Task {
                            if status == "Sent 💌" {
                                status = "Add +"
                            } else if  status == "Friends ✅" {
                                status = "Add +"
                            } else {
                                status = "Sent 💌"
                            }
                            
                            mainVM.currUser = await profileVM.tappedAdd(currUser: currUser, friend: user, currentStatus: user.friendsStatus)
                        }
                    }
                }
            }.offset(y: -8)
        }
        .padding(.horizontal, 32)
        .padding(.top)
        .onAppear {
            self.status = user.friendsStatus
        }
    }
}

struct PeopleScreen: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {                        
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(profileVM.peopleList, id: \.id) { user in
                            FriendRow(user: user)
                        }
                    }
                }
                Text("add friends to show up in their polls more!")
                    .sfPro(type: .bold, size: .p2)
                    .foregroundColor(Color.black)
                    .padding()
            }
        }
    }
}

#Preview {
    PeopleScreen()
        .environmentObject(ProfileViewModel())
}
