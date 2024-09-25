//
//  PollComplete.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftUI
import FirebaseDynamicLinks
import FacebookShare

struct PollCooldownScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @State private var timer: Timer?
    @State private var showShareSheet = false
    
    let columns = [
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24),
        GridItem(.flexible(), spacing: -24)
    ]
    
    var body: some View {
        Group {
            if pollVM.completedPoll {
                PollComplete()
                    .environmentObject(pollVM)
            } else {
                ZStack {
                    Color.primaryBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        if pollVM.isNewPollReady && pollVM.cooldownEndTime == nil {
                            Text("new polls are\navailable!")
                                .sfPro(type: .bold, size: .h1)
                                .foregroundColor(.white)
                                .padding(.top, 16)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            VStack(spacing: 16) {
                                SharedComponents.PrimaryButton(
                                    title: "Start",
                                    action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
//                                            fatalError("Crash was triggered")
                                            pollVM.isNewPollReady = false
                                            mainVM.currentPage = .poll
                                            Analytics.shared.log(event: "PollCooldown: Tapped Start")
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                        } else {
                            Text("new polls in")
                                .sfPro(type: .bold, size: .h1)
                                .foregroundColor(.white)
                                .padding(.top, 16)
                            Text("\(pollVM.timeRemainingString())")
                                .sfPro(type: .bold, size: .title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                                Text("--- or ---")
                                    .sfPro(type: .semibold, size: .h2)
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.vertical, 32)
                            VStack(spacing: 16) {
                                Text("skip the wait!")
                                    .sfPro(type: .semibold, size: .h2)
                                    .foregroundColor(.white)
                                SharedComponents.PrimaryButton(
                                    title: "Invite a friend",
                                    action: {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            showShareSheet = true
                                             createDynamicLink(username: mainVM.currUser?.username ?? "") { url in
                                                guard let url = url else { return }
                                                let image = UIImage(named: "AppIcon")
                                                let content = "I'm inviting you to download and install the ong app"
                                                
                                                let activityVC = UIActivityViewController(activityItems: [ url, TestView().snapshot(), content], applicationActivities: nil)
                                                
                                                activityVC.setValue("ONG", forKey: "subject")
                                                
                                                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)                                                
                                            }
                                        }
                                    }
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                   
                        

                  
                        Spacer()

                        VStack {
                            Text("aura leaders (today)")
                                .sfPro(type: .semibold, size: .h2)
                                .foregroundColor(.white)
                                
//                            SharedComponents.PrimaryButton(
//                                title: "share on instagram",
//                                action: {
//                                     createDynamicLink(username: mainVM.currUser?.username ?? "") { url in
//                                        guard let url = url else { return }
//                                        
//                                         
////                                         let image = TestView().snapshot()
////                                         let image = UIImage(named: "temp")
//                                         shareToInstagramStories(TestView().snapshot())
//                                     }     
//                                }
//                            )
//                            .padding(.top, 32)

                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(profileVM.topEight.prefix(8), id: \.id) { user in
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
                                    .rotationEffect(.degrees(-8))
                                    .onTapGesture {
                                        Analytics.shared.log(event: "PollCooldown: leaderboard tapped profile")
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation {
                                            profileVM.visitedUser = user
                                            profileVM.isVisitingUser = true
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        Spacer()
                        Spacer()
                    }
                    .padding(.top, 42)
                }  .sheet(isPresented: $showShareSheet) {
                    InviteFriendsModal()
                        .presentationDetents([.height(300)])
                        .presentationDragIndicator(.visible)
                }
            }
       
        }.onAppear {
            if let user = mainVM.currUser {
                pollVM.checkCooldown(user: user)
                startTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    

    
    func createDynamicLink(username: String, completion: @escaping (URL?) -> Void) {
         let link = "https://ongapp.page.link/share?user_name=\(username)"
         let dynamicLinksDomainURIPrefix = "https://ongapp.page.link"
         let linkBuilder = DynamicLinkComponents(link: URL(string: link)!, domainURIPrefix: dynamicLinksDomainURIPrefix)
         
         // Configure iOS parameters
         let iosParameters = DynamicLinkIOSParameters(bundleID: "com.ong.app")
         iosParameters.appStoreID = "6673430933" // Ensure this is the correct App Store ID
         linkBuilder?.iOSParameters = iosParameters
         
         // Shorten the link
         linkBuilder?.shorten { (shortURL, warnings, error) in
             if let error = error {
                 print("Error creating dynamic link: \(error.localizedDescription)")
                 completion(nil)
             } else if let shortURL = shortURL {
                 print("Dynamic link created: \(shortURL.absoluteString)")
                 completion(shortURL)
             }
         }
     }
    
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let cooldownEndTime = pollVM.cooldownEndTime, cooldownEndTime <= Date() {
                pollVM.cooldownEndTime = nil
                timer?.invalidate()
            }
        }
    }

 
}

struct PollCooldownScreen_Previews: PreviewProvider {
    static var previews: some View {
        PollCooldownScreen()
            .environmentObject(PollViewModel())
            .environmentObject(MainViewModel())
            .environmentObject(ProfileViewModel())

    }
}



struct TestView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = UIImage(named: "temp") {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150) // Half the height of the parent
                        .padding(20)
                        
                } else {
                    Text("Image not found")
                        .foregroundColor(.red)
                }

                Text("Hello, world!")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.1) // Ensure the text fits properly
            }
            .frame(width: geometry.size.width, height: geometry.size.height) // Ensure ZStack takes the full size
        }
    }
}


extension View {
    func snapshot() -> UIImage {
        
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        // Set an explicit size for the view
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        view?.layoutIfNeeded()
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            //        }
        }
        
        
    }
}

