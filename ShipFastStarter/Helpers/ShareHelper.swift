//
//  ShareHelper.swift
//  ONG
//
//  Created by Dante Kim on 9/23/24.
//

import Foundation
import UIKit

struct ShareHelper {
    static let shared = ShareHelper() 

    static func share(text: String, url: String) {
        let shareText = "Check out this poll: \(url)"
        // Implement general sharing logic here if needed
    }

    func shareToInstagramStories(image: UIImage) {
        // Check if Instagram Stories can be opened
        guard let instagramStoriesUrl = URL(string: "instagram-stories://share?source_application=com.ong.app") else {
            print("Error: Unable to create Instagram Stories URL")
            return
        }

        // Check if Instagram is installed
        guard UIApplication.shared.canOpenURL(instagramStoriesUrl) else {
            print("Error: Instagram is not installed")
            showInstagramNotInstalledAlert()
            return
        }

        // Prepare the image data
        guard let imageData = image.pngData() else {
            print("Error: Unable to convert image to PNG data")
            return
        }

        // Set up the pasteboard items
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.stickerImage": imageData,
            "com.instagram.sharedSticker.backgroundTopColor": "#E7D4FF",
            "com.instagram.sharedSticker.backgroundBottomColor": "#E7D4FF"
        ]

        // Set the pasteboard with the items
        UIPasteboard.general.setItems([pasteboardItems], options: [:])

        // Open Instagram Stories
        UIApplication.shared.open(instagramStoriesUrl, options: [:]) { success in
            if success {
                print("Instagram Stories opened successfully")
            } else {
                print("Error: Failed to open Instagram Stories")
            }
        }
    }

    func shareImage(image: UIImage) {
        // Get the top view controller
        guard let topViewController = UIApplication.shared.windows.first?.rootViewController else {
            print("Error: Unable to get top view controller")
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        // Exclude irrelevant activity types if desired
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .saveToCameraRoll,
            .print,
            .copyToPasteboard
        ]

        // For iPad compatibility
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = topViewController.view
            popoverController.sourceRect = CGRect(x: topViewController.view.bounds.midX,
                                                  y: topViewController.view.bounds.midY,
                                                  width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        topViewController.present(activityViewController, animated: true, completion: nil)
    }

    private func showInstagramNotInstalledAlert() {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                let alertController = UIAlertController(
                    title: "Instagram Not Installed",
                    message: "Please install Instagram to share content.",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                rootViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
