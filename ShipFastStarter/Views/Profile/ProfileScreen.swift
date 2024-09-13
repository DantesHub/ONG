//
//  ProfileScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import SwiftUI
import PhotosUI
import AVFoundation

struct ProfileScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showingActionSheet = false

    @State private var user = User.exUser
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                // profile image
                ZStack {
                    ZStack {
                        // Dotted line box
                        if !user.proPic.isEmpty {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(1), lineWidth: 4)
                                        .padding(1)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                )
                                .frame(width: 124, height: 124)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [7]))
                                .foregroundColor(.black)
                                .frame(width: 124, height: 124)
                        }
                        
                        
                        if !user.proPic.isEmpty {
                            CachedAsyncImage(url: URL(string: user.proPic)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 124, height: 124)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                case .failure:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 124, height: 124)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                                .frame(width: 124, height: 124)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        if !user.proPic.isEmpty {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black.opacity(1), lineWidth: 4)
                                        .padding(1)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                )
                                .frame(width: 124, height: 124)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            Analytics.shared.log(event: "ProfileScreen: Tapped Image")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            showingActionSheet = true
                        }
                    }
                    .primaryShadow()
                    .rotationEffect(.degrees(-12))
                    .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                    .padding(.bottom)
                    .padding(.top, 32)
                    VStack(spacing: -28) {
                        Text("\(mainVM.currUser?.friends.count ?? 0)")
                            .sfPro(type: .bold, size: .h1)
                            .stroke(color: .black, width: 3)
                        Text("friends")
                            .sfPro(type: .bold, size: .h1)
                            .stroke(color: .black, width: 3)
                    }.foregroundColor(.white)
                    .rotationEffect(.degrees(-16))
                    .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                    .offset(x: -100, y: 65)
                    VStack(spacing: -36) {
                        Text("\(mainVM.currUser?.aura ?? 0)")
                            .sfPro(type: .bold, size: .h1Big)
                            .stroke(color: .primaryBackground, width: 3)
                        Text("aura")
                            .sfPro(type: .bold, size: .h1Big)
                            .stroke(color: .primaryBackground, width: 3)
                    }.foregroundColor(.white)
                    .rotationEffect(.degrees(16))
                    .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                    .offset(x: 100)
                    .padding(.top, 24)
                }
                Text("\(user.firstName) \(user.lastName)")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(Color.black)
                    .padding(.top)
                Text("@\(user.username)")
                    .sfPro(type: .medium, size: .h2)
                    .foregroundColor(Color.black.opacity(0.4))
                    .padding(.bottom, 32)
                if profileVM.isVisitingProfile {
                    HStack {
                        SharedComponents.SecondaryButton(title: profileVM.isFriend ? "friends" : "add friend +") {
                            Analytics.shared.log(event: profileVM.isFriend ? "ProfileScreen: Tapped Unfriend" : "ProfileScreen: Tapped Add Friend")
                            
                        }
                        SharedComponents.SecondaryButton(title: profileVM.isCrush ? "crush ❤️" : "mark as crush 😻") {
                            Analytics.shared.log(event: profileVM.isFriend ? "ProfileScreen: Tapped Unmark crush" : "ProfileScreen: Tapped Mark Crush")
                                                        
                        }
                    }.padding(.horizontal)
                }
              
                SharedComponents.Divider()
                Spacer()
                Text("get ur aura up,\nmore coming soon...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
                    .opacity(0.3)
                Spacer()
            }
            
            // show highschool.
        }
        .onAppear {
            if let user = mainVM.currUser {
                self.user = user
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Select Profile Picture"), buttons: [
                .default(Text("Take a Photo")) {
                    profileVM.checkCameraPermission()
                },
                .default(Text("Choose from Library")) {
                    profileVM.checkPhotoLibraryPermission()
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $profileVM.showingImagePicker) {
            ImagePicker(sourceType: profileVM.sourceType, selectedImage: $profileVM.profileImage)
        }
        .onChange(of: profileVM.profileImage) {
            if let user = mainVM.currUser {
                UserDefaults.standard.setValue(true, forKey: "uploadedProPic")
                Task {
                    do {
                        mainVM.currUser?.proPic = try await profileVM.uploadUserProfilePicture(image: profileVM.profileImage!, user: user)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        
            }
        }
        .onAppear {
            
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ProfileScreen()
        .environmentObject(MainViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(ProfileViewModel())
}
