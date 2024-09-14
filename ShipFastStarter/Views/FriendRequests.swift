//
//  FriendRequests.swift
//  ONG
//
//  Created by Dante Kim on 9/12/24.
//

import SwiftUI

struct FriendRequests: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if inboxVM.friendRequests.isEmpty {
                            Spacer()
                            Text("No friend requests yet!\n\nTip: Add more friends to get more requests")
                                .foregroundColor(Color.black.opacity(0.7))
                                .font(.system(size: 22, weight: .bold))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 48)
                                .opacity(0.3)
                                .offset(y: 64)
                            Spacer()
                        } else {
                            Text("Friend Requests")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.leading, 20)
                                .padding(.top, 20)
                            
                            VStack(spacing: 24) {
                                ForEach(inboxVM.friendRequests) { request in
                                    FriendRequestView(request: request)
                                }
                            }
                        }
                        Spacer()
                        SharedComponents.PrimaryButton(title: "invite friends") {
                            Analytics.shared.log(event: "LockedHighschool: Tapped Invite")
                            showShareSheet.toggle()
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
                
            }
        }
        .sheet(isPresented: $showShareSheet) {
            InviteFriendsModal()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            if let user = mainVM.currUser {
                Task {
                    await inboxVM.fetchFriendRequests(for: user)
                }
            }
        }
    }
}

struct FriendRequestView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    var request: FriendRequest
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 4)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                HStack {
                    ProfilePictureView(user: request.user)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(request.user.firstName) \((request.user.lastName))")
                            .sfPro(type: .bold, size: .p2)
                        Text("\(request.user.grade)")
                            .sfPro(type: .bold, size: .p2)
                            .foregroundColor(Color.black.opacity(0.5))
                    }.padding(.leading)
                    
                    Spacer()
                    VStack {
                        AcceptButton(isPressed: $isPressed) {
                            Analytics.shared.log(event: "FriendRequests: Tapped Accept")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                mainVM.currUser?.friendRequests.removeValue(forKey: request.user.id)
                                mainVM.currUser?.friends[request.user.id] = Date().toString()

                                if let user = mainVM.currUser {
                                    Task {
                                        await inboxVM.tappedAcceptFriendRequest(currUser: user, requestedUser: request.user)
                                    }
                                }
                                withAnimation {
                                    inboxVM.friendRequests.removeAll { $0.user.id == request.user.id }
                                }
                            }
                        }
                    }
                }.padding()
            }
            .cornerRadius(16)
            .primaryShadow()
            .padding(.horizontal)
            // Circle X mark
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 24))
                .background(Circle().fill(Color.white))
                .offset(x: 8, y: -8)
                .position(x: UIScreen.main.bounds.width - 30, y: 12)
                .onTapGesture {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if let user = mainVM.currUser {
                        Analytics.shared.log(event: "FriendRequests: Tapped Decline")
                        mainVM.currUser?.friendRequests.removeValue(forKey: request.user.id)
                        
                        Task {
                            await inboxVM.tappedDeclineFriendRequest(currUser: user, requestedUser: request.user)
                        }
                    }
                    withAnimation {
                        inboxVM.friendRequests.removeAll { $0.user.id == request.user.id }
                    }
                }
        }
    }
}

struct ProfilePictureView: View {
    let user: User
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .stroke(color: .black, width: 2)
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
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }.rotationEffect(.degrees(-12))
    }
}

struct AcceptButton: View {
    @Binding var isPressed: Bool
    let action: () -> Void
    
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
            Text("Accept")
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

struct FriendRequests_Previews: PreviewProvider {
    static var previews: some View {
        FriendRequests()
            .environmentObject(InboxViewModel())
            .environmentObject(MainViewModel())
            .environmentObject(ProfileViewModel())
    }
}
