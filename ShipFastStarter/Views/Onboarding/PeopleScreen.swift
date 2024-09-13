//
//  PeopleScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import SwiftUI

struct FriendButton: View {
    @EnvironmentObject var mainVM: MainViewModel
    let user: User
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ZStack {
                    if let url = URL(string: user.proPic), !user.proPic.isEmpty {
                        CachedAsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
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
                .opacity(isSelected || mainVM.onboardingScreen != .addFriends ? 1 : 0.5)
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
            if mainVM.onboardingScreen == .addFriends {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onTap()
            }
        }
    }
}

struct PeopleScreen: View {
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
                    Text("ppl from buildspace")
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
                        ForEach(profileVM.peopleList, id: \.id) { user in
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
                if mainVM.onboardingScreen != .addFriends {
                    SharedComponents.PrimaryButton(title: "invite friends") {
                        withAnimation {
                            showShareSheet.toggle()
                        }
                    }.padding(.horizontal, 32)
                    .padding(.bottom)
                } else {
                    SharedComponents.PrimaryButton(title: "next") {
                        if let user = mainVM.currUser {
                            withAnimation {
                                mainVM.onboardingScreen = .color
                            }
                            Task {
                                let selectedUsers = profileVM.peopleList.filter { selectedFriends.contains($0.id) }
                                mainVM.currUser = await profileVM.addFriends(currUser: user, users: selectedUsers)
                            }
                        }
                    }.padding(.horizontal, 32)
                    .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            InviteFriendsModal()
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            preloadImages()
        }
    }
    
    private func preloadImages() {
        let imageUrls = profileVM.peopleList.compactMap { URL(string: $0.proPic) }
        Task {
            await ImageCache.shared.preloadImages(urls: imageUrls)
        }
    }
}

struct PeopleScreen_Previews: PreviewProvider {
    static var previews: some View {
        PeopleScreen()
            .environmentObject(ProfileViewModel())
            .environmentObject(MainViewModel())
    }
}
