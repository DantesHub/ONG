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
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var feedVM: FeedViewModel

    @State private var showingActionSheet = false
    @State private var showAboutScreen = false
    @State private var showEditProfile = false
    @State private var user: User
    @State private var isFriendRequest = false
    @State private var isFriends = false
    @State private var sentRequest = false
    @State private var showSettings = false
    @State private var isOriginalProfileScreen = false
    
    init(user: User? = nil) {
        _user = State(initialValue: user ?? User.exUser)
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                InboxScreen().customToolbar
                if profileVM.isVisitingUser {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .onTapGesture {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation {
                                    profileVM.isVisitingUser = false
                                }
                            }
                            .foregroundColor(.black)
                        Spacer()
                    }.padding(.top)
                    .padding(.horizontal)
                }
                // profile image
                ScrollView(showsIndicators: false) {
                    
                    ZStack {
                        ZStack {
                            // Dotted line box
                            if user.proPic.isEmpty {
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
                            
                            if profileVM.isVisitingUser && !isOriginalProfileScreen {
                                if let url = URL(string: profileVM.visitedUser?.proPic ?? "") {
                                    CachedAsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 124, height: 124)
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
                                    .frame(width: 124, height: 124)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                }
                            } else {
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
                            }
                            
                            
                            if user.proPic.isEmpty {
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
                            if !profileVM.isVisitingUser {
                                withAnimation {
                                    Analytics.shared.log(event: "ProfileScreen: Tapped Image")
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    showingActionSheet = true
                                }
                            }
                            
                        }
                        .primaryShadow()
                        .rotationEffect(.degrees(-12))
                        .shadow(color: .black.opacity(0.7), radius: 0, x: 3, y: 3)
                        .padding(.bottom)
                        .padding(.top, 32)
                        if !profileVM.isVisitingUser {
                            ZStack {
                                Text("\(mainVM.currUser?.bread ?? 0)")
                                    .sfPro(type: .bold, size: .h1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.breadYellow)
                                    .stroke(color: .breadBrown, width: 2)
                                    .shadow(color: .breadBrown, radius: 1, y: 3)
                                Text("bread")
                                    .sfPro(type: .bold, size: .h1)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.breadYellow)
                                    .stroke(color: .breadBrown, width: 1)
                                    .shadow(color: .breadBrown, radius: 1, y: 3)
                                    .offset(x: 0, y: 24)
                            }
                            .rotationEffect(.degrees(-8))
                            
                            .shadow(color: .breadBrown.opacity(1), radius: 0, x: 2, y: 3)
                            .offset(x: -90, y: -32)
                        }
                        VStack(spacing: -28) {
                            Text("\(profileVM.isVisitingUser && !isOriginalProfileScreen ? user.friends.count : profileVM.friends.count)")
                                .sfPro(type: .bold, size: .h1)
                                .stroke(color: .black, width: 3)
                            Text("homies")
                                .sfPro(type: .bold, size: .h1)
                                .stroke(color: .black, width: 3)
                        }.foregroundColor(.white)
                            .rotationEffect(.degrees(8))
                            .shadow(color: .black.opacity(1), radius: 0, x: 3, y: 2)
                            .offset(x: -60, y: 70)
                            .onTapGesture {
                                if !profileVM.isVisitingUser {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        Analytics.shared.log(event: "ProfileScreen: Tapped Friends")
                                        profileVM.showFriendsScreen = true
                                    }
                                }
                            }
                        VStack(spacing: -36) {
                            Text(formatAura(profileVM.isVisitingUser ? user.aura : mainVM.currUser?.aura ?? 0))
                                .sfPro(type: .bold, size: .h1Big)
                                .stroke(color: .primaryBackground, width: 3)
                            Text("aura")
                                .sfPro(type: .bold, size: .h1Big)
                                .stroke(color: .primaryBackground, width: 3)
                        }.foregroundColor(.white)
                            .rotationEffect(.degrees(16))
                            .shadow(color: .primaryBackground.opacity(1), radius: 0, x: 3, y: 3)
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
                    Text("\(user.firstName) \(user.lastName)")
                        .sfPro(type: .bold, size: .h1)
                        .foregroundColor(Color.black)
                        .padding(.top)
                    Text("@\(user.username)")
                        .sfPro(type: .medium, size: .h2)
                        .foregroundColor(Color.black.opacity(0.4))
                        .padding(.bottom, 12)
                    if profileVM.visitedUser != nil {
                        HStack {
                            SharedComponents.SecondaryButton(title: sentRequest ? "Sent 💌" : isFriends ? "friends ✅" : isFriendRequest ? "Accept +" : "add friend +" ) {
                                Analytics.shared.log(event: profileVM.isFriend ? "ProfileScreen: Tapped Unfriend" : "ProfileScreen: Tapped Add Friend")
                                mainVM.currUser?.friendRequests.removeValue(forKey: user.id)
                                mainVM.currUser?.friends[user.id] = Date().toString(format: "yyyy-MM-dd HH:mm:ss")
                                if let currUser = mainVM.currUser {
                                    if isFriendRequest {
                                        Task {
                                            await inboxVM.tappedAcceptFriendRequest(currUser: currUser, requestedUser: user)
                                        }
                                        if isFriendRequest {
                                            isFriends = true
                                        }
                                        isFriendRequest = false
                                    } else {
                                        Task {
                                            await profileVM.addFriends(currUser: currUser, users: [user])
                                        }
                                        sentRequest = true
                                    }
                                }
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
                                showSettings = true
                            }
                        }.padding(.horizontal)
                        
                    }
                    
                    SharedComponents.Divider().opacity(0.75)
                        .padding(.top)
                    
                    // about section
                    VStack(alignment: .leading, spacing: 16) {
                        aboutSectionItem(icon: "quote.opening", text: profileVM.isVisitingUser ? user.bio : mainVM.currUser?.bio ?? "")
                        aboutSectionItem(icon: "heart.fill", text: profileVM.isVisitingUser ? user.relationshipStatus : mainVM.currUser?.relationshipStatus ?? "")
                        aboutSectionItem(icon: "movieclapper.fill", text: profileVM.isVisitingUser ? user.movie : mainVM.currUser?.movie ?? "")
                        aboutSectionItem(icon: "brain.head.profile", text: profileVM.isVisitingUser ? user.mbti : mainVM.currUser?.mbti ?? "")
                        aboutSectionItem(icon: "music.note", text: profileVM.isVisitingUser ? user.music : mainVM.currUser?.music ?? "")
                    }
                    .foregroundColor(.black)
                    .padding()
                    LazyVStack(spacing: 32) {
                        ForEach(feedVM.userPosts) { post in
                            ZStack {
                                FeedPostRow(post: post)
                                //                                        .onAppear {
                                //                                            if post == feedVM.feedPosts.last {
                                //                                                feedVM.fetchNextPage()
                                //                                            }
                                //                                        }
                                    .padding(.horizontal)
                                Text("\(post.aura)")
                                    .foregroundColor(.white)
                                    .sfPro(type: post.aura <= 50 ? .regular : post.aura <= 125  ? .medium : post.aura <= 200 ? .semibold : .bold, size: post.aura <= 50 ? .h1Small : post.aura <= 125  ? .h1 : post.aura <= 200 ? .h1Big : .title)
                                    .stroke(color: post.aura <= 50 ? .black : post.aura <= 125  ? .red : post.aura <= 200 ? Color("pink") : Color("primaryBackground"), width: 3)
                                    .shadow(color: .black.opacity(0.5), radius: 4)
                                    .rotationEffect(.degrees(16))
                                    .padding(8)
                                    .cornerRadius(8)
                                    .position(x: UIScreen.main.bounds.width / (post.aura > 200 ? 1.2 :  1.14), y: 12)
                            }
                            
                        }
                    }.padding(.top, 32)
                    Spacer()
                }
            }
            // show highschool.
        }
      
        .sheet(isPresented: $showSettings) {
            SettingsScreen(showSettings: $showSettings)
                .environmentObject(mainVM)
        }
        .onAppear {
            if profileVM.isVisitingUser {
                isOriginalProfileScreen = false
            } else {
                isOriginalProfileScreen = true
            }
            updateUser()
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
        }.onDisappear {
            isFriendRequest = false
            sentRequest = false
            isFriends = false
            profileVM.visitedUser = nil            
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
    
    private func updateUser() {
        if profileVM.isVisitingUser {
            if let visitedUser = profileVM.visitedUser {
                feedVM.visitingUser = visitedUser
                feedVM.processPollsForUserFeed()
                self.user = visitedUser
                if let currUser = mainVM.currUser {
                    if currUser.friendRequests.contains(where: { (k, v) -> Bool in
                            return k == visitedUser.id
                        }) {
                        isFriendRequest = true
                        isFriends = false
                    } else {
                        isFriendRequest = false
                    }
                        if currUser.friends.contains(where: { (k, v) -> Bool in
                                return k == visitedUser.id
                        }) {
                            isFriends = true
                        }
                }
            }
        } else {
            if let currentUser = mainVM.currUser {
                feedVM.visitingUser = currentUser
                feedVM.processPollsForUserFeed()

                DispatchQueue.main.async {
                    self.user = currentUser
                }
            }
        }
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
        
        // Set the default camera to front
        if sourceType == .camera {
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        }
        
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
        .environmentObject(FeedViewModel())
        .environmentObject(ProfileViewModel())
}
