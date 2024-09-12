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
                                        
                                        let activityVC = UIActivityViewController(activityItems: [ url, image, content], applicationActivities: nil)
                                        
                                        activityVC.setValue("ONG", forKey: "subject")
                                        
                                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                                        
                                    }
                                }
                            )
                            SharedComponents.PrimaryButton(
                                title: "share on facebook",
                                action: {
                                     createDynamicLink(username: "Test_user1") { url in
                                        guard let url = url else { return }
                                        
                                        let content = "I'm inviting you to download and install the ong app"
                                        shareToFacebook(quote: content, url: url)
                                       
                                        //
                                        //
                                        //
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
