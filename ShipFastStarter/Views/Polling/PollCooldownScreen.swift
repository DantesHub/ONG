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
    @EnvironmentObject var mainVM: MainViewModel
    @State private var timer: Timer?

    var body: some View {
        Group {
            if pollVM.completedPoll {
                PollComplete()
                    .environmentObject(pollVM)
            } else {
                ZStack {
                    Color.primaryBackground.ignoresSafeArea()
                    VStack(spacing: 0) {
                        Text("new polls in")
                            .sfPro(type: .bold, size: .h1)
                            .foregroundColor(.white)
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
                                    createDynamicLink(username: mainVM.currUser?.username ?? "") { url in
                                        guard let url = url else { return }
                                        let image = UIImage(named: "AppIcon")
                                        let content = "I'm inviting you to download and install the ong app"
                                        
                                        let activityVC = UIActivityViewController(activityItems: [ url, TestView().snapshot(), content], applicationActivities: nil)
                                        
                                        activityVC.setValue("ONG", forKey: "subject")
                                        
                                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                                        
                                    }
                                }
                            )
                            TestView()
                            SharedComponents.PrimaryButton(
                                title: "share on facebook",
                                action: {
                                     createDynamicLink(username: mainVM.currUser?.username ?? "") { url in
                                        guard let url = url else { return }
                                        
                                        let content = "I'm inviting you to download and install the ong app"
                                        shareToFacebook(quote: content, url: url)
                                     
                                    }
                                }
                            )
                            SharedComponents.PrimaryButton(
                                title: "share on instagram",
                                action: {
                                     createDynamicLink(username: mainVM.currUser?.username ?? "") { url in
                                        guard let url = url else { return }
                                        
                                         
//                                         let image = TestView().snapshot()
//                                         let image = UIImage(named: "temp")
                                         shareToInstagramStories(TestView().snapshot())
                                       
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // HStack(spacing: 24) {
                        //     ForEach(["🔥", "😂", "😍", "👀", "💯"], id: \.self) { emoji in
                        //         Text(emoji)
                        //             .font(.system(size: 40))
                        //     }
                        // }
                        // .padding(.bottom, 32)
                    }
                    .padding(.top, 64)
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
    
    
    func shareToInstagramStories(_ image: UIImage) {
        guard let instagramStoriesUrl = URL(string: "instagram-stories://share?source_application=com.ong.app") else { return }
        guard let imageData = image.pngData() else { return }
//                jpegData(compressionQuality: 0.8) else { return } // Use JPEG compression
//        guard let linkUrl = URL(string: link) else { return }  Validate the link URL
        if UIApplication.shared.canOpenURL(instagramStoriesUrl) {
            let pasteboardItems: [String: Any] = [
                
                     "com.instagram.sharedSticker.backgroundTopColor": "#636e72",
                     "com.instagram.sharedSticker.backgroundBottomColor": "#b2bec3",
                "com.instagram.sharedSticker.stickerImage": imageData,
                
                
                
            ]
            UIPasteboard.general.setItems([pasteboardItems], options: [:])
            //           UIApplication.shared.open(instagramStoriesUrl, options: [:], completionHandler: nil)
            UIApplication.shared.open(instagramStoriesUrl, options: [:]) { success in
                if !success {
                    print("Failed to open Instagram Stories")
                }
            }
        } else {
            let alertController = UIAlertController(title: "Instagram Not Installed", message: "Please install Instagram to share content.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            UIApplication.shared.windows.first?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func shareToFacebook(quote: String, url: URL) {
           // Create the content to share
           let content = ShareLinkContent()
           content.contentURL = url // Replace with your content URL
        
           content.quote = quote // Optional: Add a quote
        
           // Configure the share dialog
           let dialog = ShareDialog(
            viewController: UIApplication.shared.windows.first?.rootViewController,
               content: content,
               delegate: nil
           )

           // Show the share dialog if possible
           if dialog.canShow {
               

               dialog.show()
           } else {
               print("Unable to show the Facebook share dialog.")
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

