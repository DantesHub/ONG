//
//  OnboardingScreen.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI
import FirebaseDynamicLinks
import FacebookCore
import FacebookShare

struct OnboardingScreen: View {
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    ZStack {
                        Text("ONG")
                            .sfPro(type: .black, size: .logo)
                            .frame(maxWidth: .infinity)
                            .rotationEffect(.degrees(-12))
                            .foregroundColor(.white)
                            .stroke(color: .black, width: 11)
                        Text("ONG")
                            .sfPro(type: .black, size: .logo)
                            .frame(maxWidth: .infinity)
                            .rotationEffect(.degrees(-12))
                            .foregroundColor(.white)
                            .stroke(color: .black, width: 11)
                            .offset(y: -4)
                    }
                    Spacer()
                   
                }
                Text("a social network for your high school.")
                    .sfPro(type: .bold, size: .h1Big)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top)
                Spacer()
//                SharedComponents.PrimaryButton(title: "share") {
//                    createDynamicLink(username: "Test_user1") { url in
//                        guard let url = url else { return }
//                        let image = UIImage(named: "AppIcon")
//                        let content = "I'm inviting you to download and install the ong app"
//                        shareToFacebook(quote: content, url: url)
//                       
//                        //
//                        //
//                        //
//                    }
//                    
//                    
////                    createDynamicLink(username: "Test_user1") { url in
////                        guard let url = url else { return }
////                        let image = UIImage(named: "AppIcon")
////                        let content = "I'm inviting you to download and install the ong app"
////                        
////                        let activityVC = UIActivityViewController(activityItems: [ url, image, content], applicationActivities: nil)
////                        
////                        activityVC.setValue("ONG", forKey: "subject")
////                        
////                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
////                    //
////                    //
////                    //       
////                    }
//                }.padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                
                SharedComponents.PrimaryButton(title: "continue") {
                    mainVM.currUser = User.exUser
                    mainVM.onboardingScreen = .birthday
                    
                    
//                    createDynamicLink(username: "1") { url in
//                        guard let url = url else { return }
//                        let image = UIImage(named: "AppIcon")
//                        let content = "I'm inviting you to download and install the ong app"
//
//                        let activityVC = UIActivityViewController(activityItems: [ url, image, content], applicationActivities: nil)
//                        
//                        activityVC.setValue("ONG", forKey: "subject")
//                        
//                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
//                        
//                        
//                    }
                }
                .padding(.vertical, 48)
                .padding(.horizontal, 24)
            }
        }.frame(maxWidth: .infinity, alignment: .center)
       
    }
    func shareToInstagramStories() {
        guard let image = UIImage(named: "AppIcon"), // Replace with your image
              let imageData = image.pngData() else { return }
        
        // Create the pasteboard item with the image data
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]
        
        // Set the pasteboard items
        UIPasteboard.general.setItems([pasteboardItems], options: [:])
        
        // Open Instagram Stories
        if let url = URL(string: "instagram-stories://share"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Instagram Stories is not available.")
        }
    }
    
//    func shareToInstagram() {
//           // Prepare the image to share
//           guard let image = UIImage(named: "AppIcon") else { return } // Use your image name here
//           guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
//           
//           // Save the image to a temporary location
//           let filename = FileManager.default.temporaryDirectory.appendingPathComponent("tempInstagramPhoto.jpg")
//           do {
//               try imageData.write(to: filename)
//           } catch {
//               print("Failed to save image: \(error)")
//               return
//           }
//           
//           // Set up the document interaction controller
//           let documentController = UIDocumentInteractionController(url: filename)
//           documentController.uti = "com.instagram.exclusivegram"
//           documentController.delegate = UIApplication.shared.windows.first?.rootViewController as? UIDocumentInteractionControllerDelegate
//           
//           // Present the Instagram sharing dialog
//           if let rootVC = UIApplication.shared.windows.first?.rootViewController {
//               documentController.presentOpenInMenu(from: rootVC.view.frame, in: rootVC.view, animated: true)
//           }
//       }
    
    
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
}

#Preview {
    OnboardingScreen()
}

struct StrokedText: ViewModifier {
    let fillColor: Color
    let strokeColor: Color
    let strokeWidth: CGFloat
    @State private var isShowingShareSheet = false
    @State private var shareItems: [Any] = []

    func body(content: Content) -> some View {
        ZStack {
            content.foregroundColor(strokeColor)
            content.foregroundColor(fillColor)
                .offset(x: strokeWidth, y: strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: -strokeWidth, y: -strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: -strokeWidth, y: strokeWidth)
            content.foregroundColor(fillColor)
                .offset(x: strokeWidth, y: -strokeWidth)
        }
    }
}

extension View {
    func stroke(color: Color, width: CGFloat = 1) -> some View {
        modifier(StrokeModifier(strokeSize: width, strokeColor: color))
    }
}

struct StrokeModifier: ViewModifier {
    private let id = UUID()
    var strokeSize: CGFloat = 1
    var strokeColor: Color = .blue

    func body(content: Content) -> some View {
        if strokeSize > 0 {
            appliedStrokeBackground(content: content)
        } else {
            content
        }
    }

    private func appliedStrokeBackground(content: Content) -> some View {
        content
            .padding(strokeSize*2)
            .background(
                Rectangle()
                    .foregroundColor(strokeColor)
                    .mask(alignment: .center) {
                        mask(content: content)
                    }
            )
    }

    func mask(content: Content) -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.01))
            if let resolvedView = context.resolveSymbol(id: id) {
                context.draw(resolvedView, at: .init(x: size.width/2, y: size.height/2))
            }
        } symbols: {
            content
                .tag(id)
                .blur(radius: strokeSize)
        }
    }
}


