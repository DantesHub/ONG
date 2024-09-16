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
    @State private var showAboutScreen = false
    @State private var showEditProfile = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                // profile image
                ZStack {
                    ZStack {
                        // Dotted line box
                        if let currUser = mainVM.currUser, currUser.proPic.isEmpty {
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
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [7]))
                                .foregroundColor(.black)
                                .frame(width: 124, height: 124)
                        }
                        
                        
                        if let img = profileVM.profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 124, height: 124)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 124, height: 124)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        if let currUser = mainVM.currUser, currUser.proPic.isEmpty {
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
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            Analytics.shared.log(event: "ProfileScreen: Tapped Friends")
                            profileVM.showFriendsScreen = true
                        }
                    }
                    VStack(spacing: -36) {
                        Text(formatAura(mainVM.currUser?.aura ?? 0))
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
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation {
                            Analytics.shared.log(event: "ProfileScreen: Tapped Aura")
                            showAboutScreen = true
                        }
                    }
                }
                Text("\(mainVM.currUser?.firstName ?? "") \(mainVM.currUser?.lastName ?? "")")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(Color.black)
                    .padding(.top)
                Text("@\(mainVM.currUser?.username ?? "")")
                    .sfPro(type: .medium, size: .h2)
                    .foregroundColor(Color.black.opacity(0.4))
                    .padding(.bottom, 12)
                if profileVM.isVisitingProfile {
                    HStack {
                        SharedComponents.SecondaryButton(title: profileVM.isFriend ? "friends" : "add friend +") {
                            Analytics.shared.log(event: profileVM.isFriend ? "ProfileScreen: Tapped Unfriend" : "ProfileScreen: Tapped Add Friend")
                            
                        }
                        SharedComponents.SecondaryButton(title: profileVM.isCrush ? "crush ❤️" : "mark as crush 😻") {
                            Analytics.shared.log(event: profileVM.isFriend ? "ProfileScreen: Tapped Unmark crush" : "ProfileScreen: Tapped Mark Crush")
                        }
                    }.padding(.horizontal)
                } else { // users own profile
                    HStack {
                        SharedComponents.SecondaryButton(title: "Edit Profile") {
                            Analytics.shared.log(event: "ProfileScreen: Tapped Edit Profile")
                            showEditProfile = true
                        }
                        
                        SharedComponents.SecondaryButton(title: "Settings") {
                            Analytics.shared.log(event: "ProfileScreen: Tapped Edit Settings")
                            
                        }
                    }.padding(.horizontal)
                 
                }
              
                SharedComponents.Divider().opacity(0.75)
                    .padding(.top)
                Spacer()
                
                // about section
                VStack(alignment: .leading, spacing: 16) {
                    aboutSectionItem(icon: "quote.opening", text: mainVM.currUser?.bio ?? "")
                    aboutSectionItem(icon: "heart.fill", text: mainVM.currUser?.relationshipStatus ?? "")
                    aboutSectionItem(icon: "movieclapper.fill", text: mainVM.currUser?.movie ?? "")
                    aboutSectionItem(icon: "music.note", text: mainVM.currUser?.music ?? "")
                    aboutSectionItem(icon: "brain.head.profile", text: mainVM.currUser?.mbti ?? "")
                    Spacer()
                }
                .foregroundColor(.black)
                .padding()
                Spacer()
            }
            // show highschool.
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
                .environmentObject(profileVM)
                .environmentObject(mainVM)
                .colorScheme(.light)
        }
        .sheet(isPresented: $showAboutScreen) {
            AboutScreen()
        }
        .sheet(isPresented: $profileVM.showFriendsScreen) {
            FriendsScreen()
                .environmentObject(profileVM)
                .environmentObject(mainVM)
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
//        .onChange(of: profileVM.profileImage) {
//            if let user = mainVM.currUser {
//                UserDefaults.standard.setValue(true, forKey: "uploadedProPic")
//                Task {
//                    do {
//                        mainVM.currUser?.proPic = try await profileVM.uploadUserProfilePicture(image: profileVM.profileImage!, user: user)
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//        
//            }
//        }
    }
    
    // Add this function to format the aura number without commas
    private func formatAura(_ aura: Int) -> String {
        return "\(aura)"
    }
    
    private func aboutSectionItem(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black.opacity(0.3))
                .frame(width: 24, height: 24)
            Text(text)
                .sfPro(type: .semibold, size: .h3p1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    
    @State private var relationshipStatus: String = ""
    @State private var movie: String = ""
    @State private var music: String = ""
    @State private var mbti: String = ""
    @State private var bio: String = ""
    @State private var grade: String = ""
    @State private var gender: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("About You").foregroundColor(.black)) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundColor(.gray)
                        TextField("ur oneliner", text: $bio)
                    }
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.gray)
                        TextField("Relationship Status", text: $relationshipStatus)
                    }
                    HStack {
                        Image(systemName: "movieclapper.fill")
                            .foregroundColor(.gray)
                        TextField("Movie", text: $movie)
                    }
                    HStack {
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                        TextField("Music", text: $music)
                    }
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.gray)
                        TextField("MBTI", text: $mbti)
                            
                    }
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.gray)
                        Picker("Gender", selection: $gender) {
                            Text("Male").tag("male")
                            Text("Female").tag("female")
                            Text("Other").tag("other")
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.blue),
                trailing: Button("Save") {
                    saveProfile()
                }
                .foregroundColor(.blue)
            )
            .background(Color.white)
        }
        .accentColor(.black)
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let user = mainVM.currUser else { return }
        relationshipStatus = user.relationshipStatus
        movie = user.movie
        music = user.music
        mbti = user.mbti
        grade = user.grade
        gender = user.gender
        bio = user.bio
    }
    
    private func saveProfile() {
        guard var updatedUser = mainVM.currUser else { return }
        updatedUser.relationshipStatus = relationshipStatus
        updatedUser.movie = movie
        updatedUser.music = music
        updatedUser.mbti = mbti
        updatedUser.bio = bio
        updatedUser.grade = grade
        updatedUser.gender = gender
        
        Task {
            do {
                try await profileVM.updateUserProfile(updatedUser)
                DispatchQueue.main.async {
                    mainVM.currUser = updatedUser
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Error updating profile: \(error.localizedDescription)")
            }
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
