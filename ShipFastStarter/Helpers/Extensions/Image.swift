//
//  Image.swift
//  ONG
//
//  Created by Dante Kim on 9/9/24.
//

import Foundation
import SwiftUI
import UIKit

extension Image {
    func toUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self.resizable().aspectRatio(contentMode: .fit))
        
        guard let view = controller.view else { return nil }
        
        let contentSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: contentSize)
        view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: contentSize)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
