//
//  ImageUploadExtension.swift
//  ONG
//
//  Created by Dante Kim on 9/12/24.
//

import SwiftUI
import AVFoundation
import Photos

protocol ImageUploadable: AnyObject {
    var showingImagePicker: Bool { get set }
    var sourceType: UIImagePickerController.SourceType { get set }
    
    func checkCameraPermission()
    func checkPhotoLibraryPermission()
}





extension ImageUploadable {
    func checkCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.sourceType = .camera
                    self.showingImagePicker = true
                } else {
                    // Handle camera permission denied
                    print("Camera permission denied")
                }
            }
        }
    }
    
    func checkPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self.sourceType = .photoLibrary
                    self.showingImagePicker = true
                case .denied, .restricted:
                    // Handle photo library permission denied
                    print("Photo library permission denied")
                case .notDetermined:
                    // This shouldn't be reached, but handle just in case
                    print("Photo library permission not determined")
                @unknown default:
                    break
                }
            }
        }
    }
}

