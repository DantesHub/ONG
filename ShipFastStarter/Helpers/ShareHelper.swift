//
//  ShareHelper.swift
//  ONG
//
//  Created by Dante Kim on 9/23/24.
//

import Foundation

struct ShareHelper {
    static let shared = ShareHelper() 

    static func share(text: String, url: String) {
        let shareText = "Check out this poll: \(url)"
        let shareURL = URL(string: url)
//        let shareActivity = UIActivityViewController(activityItems: [shareText, shareURL], applicationActivities: nil)
//        UIApplication.shared.windows.first?.rootViewController?.present(shareActivity, animated: true, completion: nil)
    }

    
}
