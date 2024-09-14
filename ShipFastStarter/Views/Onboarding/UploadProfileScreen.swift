//
//  UploadProfileScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/11/24.
//

import SwiftUI

struct UploadProfileScreen: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                Spacer()
                Text("add a profile photo")
                    .sfPro(type: .bold, size: .h1)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.white)
                    .padding(.horizontal)
                Text("add a photo so your friends can find you on ong. ")
                    .sfPro(type: .medium, size: .p2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 56)
                    .foregroundColor(Color.white)
                Spacer()
               
                ZStack {
                 
                    if let profileImage = profileVM.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        RoundedRectangle(cornerRadius: 16)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(1), lineWidth: 7)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(1), lineWidth: 7)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 64, height: 64)
                            .foregroundColor(.black.opacity(0.8))
                            .cornerRadius(16)
                    }   
                    
         
                }
                .frame(width: 200, height: 200)
                .primaryShadow()
                .rotationEffect(.degrees(-12))
                .padding(32)
                Spacer()
                if let profileImage = profileVM.profileImage {
                    SharedComponents.PrimaryButton(title: "change") {
                        profileVM.profileImage = nil
                    }.padding(.horizontal, 32)
                    .padding(.top)
                    SharedComponents.PrimaryButton(title: "next") {
                        if let user = mainVM.currUser {
                            Task {
                                do {
                                    mainVM.currUser?.proPic = try await profileVM.uploadUserProfilePicture(image: profileVM.profileImage!, user: user)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            mainVM.onboardingScreen = .highschool
                        }
                    }.padding(.horizontal, 32)
                    .padding(.bottom)
                } else {
                    SharedComponents.PrimaryButton(title: "choose a photo") {
                        Analytics.shared.log(event: "ProfilePic: Tapped Choose a showingImagePicker")
                        profileVM.checkPhotoLibraryPermission()
                    }.padding(.horizontal, 32)
                    .padding(.top)
                    SharedComponents.PrimaryButton(title: "take a stunning selfie") {
                        profileVM.checkCameraPermission()
                        Analytics.shared.log(event: "ProfilePic: Tapped take a selfie")
                    }.padding(.horizontal, 32)
                    .padding(.bottom)
                }
            
            }
            .sheet(isPresented: $profileVM.showingImagePicker) {
                ImagePicker(sourceType: profileVM.sourceType, selectedImage: $profileVM.profileImage)
            }
        }
    }
}

#Preview {
    UploadProfileScreen()
}
