//
//  PollAnswerDetailView.swift
//  ONG
//
//  Created by Dante Kim on 9/22/24.
//

import Foundation
import SwiftUI
import UIKit
import Photos
import MessageUI

struct PollAnswerDetailView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var pollVM: PollViewModel
    @State private var tappedReveal = false
    @State private var capturedImage: UIImage?
    @State private var showPhotoPermissionAlert = false
    @State private var isShareSheetPresented = false
    @State private var isCapturingImage = false

    var body: some View {
        ZStack {
            Color.lightPurple.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Close button (outside of the screenshot)
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                inboxVM.tappedNotification = false
                            }
                        }
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal, 32)

                // Content to be captured
                PollAnswerContentView()
                    .environmentObject(inboxVM)
                    .environmentObject(mainVM)
                    .environmentObject(pollVM)
                    .padding(.bottom, 20) // Add bottom padding to ensure content is not cut off

                // Capture buttons (not included in screenshot)
                HStack(spacing: 0) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "2A2A2A"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black.opacity(0.7), lineWidth: 5)
                                        .padding(1)
                                        .mask(RoundedRectangle(cornerRadius: 16))
                                )
                            HStack {
                                Text("reveal 🤐")
                                    .sfPro(type: .bold, size: .h3p1)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.horizontal, 32)
                        }
                        .primaryShadow()
                        .padding(.horizontal)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                tappedReveal.toggle()
                            }
                        }
                    }

                    // Instagram Button
                    ZStack(alignment: .center) {
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink, .orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.7), lineWidth: 5)
                                .padding(1)
                                .mask(RoundedRectangle(cornerRadius: 16))
                        )

                        Image("instaLogo")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.white)
                    }
                    .frame(width: 72, height: 72)
                    .primaryShadow()
                    .padding(.trailing, 12)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        checkPhotoPermissionAndShare(forInstagram: true)
                        Analytics.shared.log(event: "PollAnswerDetailView: Tapped Share Insta")
                    }

                    // iMessage Button
                    ZStack(alignment: .center) {
                        Color.green
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.7), lineWidth: 5)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                            )

                        Image(systemName: "message.fill")
                            .resizable()
                            .frame(width: 36, height: 32)
                            .foregroundColor(.white)
                    }
                    .frame(width: 72, height: 72)
                    .primaryShadow()
                    .padding(.trailing, 12)
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        checkPhotoPermissionAndShare(forInstagram: false)
                        Analytics.shared.log(event: "PollAnswerDetailView: Tapped Share iMessage")
                    }
                }
                .frame(height: 72)
                .disabled(inboxVM.selectedInbox?.userId == "ongteam")
                .opacity(inboxVM.selectedInbox?.userId == "ongteam" ? 0.3 : 1)
            }
        }
        .sheet(isPresented: $tappedReveal) {
            RevealModal()
        }
        .alert(isPresented: $showPhotoPermissionAlert) {
            Alert(
                title: Text("Photo Permission Required"),
                message: Text("We need access to your photos to save and share the image. Please grant permission in Settings."),
                primaryButton: .default(Text("Open Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isShareSheetPresented, content: {
            if let image = capturedImage {
                ActivityView(activityItems: [image])
                    .presentationDetents([.medium])  // This line changes the share sheet to a half sheet
            }
        })
        .onChange(of: isCapturingImage) { newValue in
            if !newValue && capturedImage != nil {
                isShareSheetPresented = true
            }
        }
    }

    private func checkPhotoPermissionAndShare(forInstagram: Bool = true) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            isCapturingImage = true
            DispatchQueue.main.async {
                self.captureAndShare(forInstagram: forInstagram)
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.isCapturingImage = true
                        self.captureAndShare(forInstagram: forInstagram)
                    } else {
                        self.showPhotoPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showPhotoPermissionAlert = true
        default:
            break
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func captureAndShare(forInstagram: Bool) {
        captureScreenshot()
        if let image = capturedImage {
            if forInstagram {
                ShareHelper.shared.shareToInstagramStories(image: image)
            }
            // We'll set isCapturingImage to false, which will trigger the sheet presentation
            isCapturingImage = false
        } else {
            print("Error: No captured image available for sharing")
            isCapturingImage = false
        }
    }

    private func captureScreenshot() {
        // Create the content view to capture
        let contentView = PollAnswerContentView()
            .environmentObject(inboxVM)
            .environmentObject(mainVM)
            .environmentObject(pollVM)
            .frame(width: UIScreen.main.bounds.width) // Ensure the content view has the correct width

        // Calculate the exact size of the content
        let targetSize = contentView.intrinsicContentSize()
        let adjustedSize = CGSize(width: targetSize.width, height: targetSize.height)

        // Create a hosting controller with the content view
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.bounds = CGRect(origin: .zero, size: adjustedSize)
        hostingController.view.backgroundColor = UIColor.clear

        // Render the view to an image
        let renderer = UIGraphicsImageRenderer(size: adjustedSize)
        let image = renderer.image { _ in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }

        // Add watermark and corner radius
        let watermarkedImage = addWatermarkAndCornerRadius(to: image)
        self.capturedImage = watermarkedImage

        // Debug: Save image to photo library (optional)
        // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    private func addWatermarkAndCornerRadius(to image: UIImage) -> UIImage? {
        let padding: CGFloat = 20
        let cornerRadius: CGFloat = 20 // Adjust this value to change the corner radius
        let newSize = CGSize(width: image.size.width, height: image.size.height + padding)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        let watermarkedImage = renderer.image { ctx in
            // Create a path for the rounded rectangle
            let rect = CGRect(origin: .zero, size: newSize)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            ctx.cgContext.addPath(path.cgPath)
            ctx.cgContext.clip()

            // Draw the background color (use your app's background color here)
            UIColor(Color.lightPurple).setFill()
            ctx.fill(rect)

            // Draw the image
            image.draw(at: CGPoint(x: 0, y: 0))

            // Add watermark
            let watermark = "ongapp.com ❤️"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.white.withAlphaComponent(1)
            ]

            let textSize = watermark.size(withAttributes: attributes)
            let rectForWatermark = CGRect(
                x: 24,
                y: newSize.height - textSize.height - padding / 2,
                width: textSize.width,
                height: textSize.height
            )

            watermark.draw(in: rectForWatermark, withAttributes: attributes)
        }
        return watermarkedImage
    }
}

// The extracted content view to capture
struct PollAnswerContentView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var pollVM: PollViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Poll question
            VStack(spacing: 8) {
                HStack(alignment: .center) {
                    // Hide the left xmark icon in the screenshot
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .opacity(0)
                    Spacer()
                    Text(inboxVM.selectedInbox?.gender == "boy" ? "👦" : "👧")
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(inboxVM.selectedInbox?.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.2), lineWidth: 8)
                        )
                        .cornerRadius(8)
                        .rotationEffect(.degrees(-12))
                    Spacer()
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .opacity(0)
                }
                .padding([.top, .horizontal], 32)

                Text("from a \(inboxVM.selectedInbox?.gender ?? "boy") in \(inboxVM.selectedInbox?.grade ?? "")")
                    .sfPro(type: .semibold, size: .h3p1)
                    .padding(.top, 8)

                Text(inboxVM.selectedPoll?.title ?? "")
                    .sfPro(type: .bold, size: .h2)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    .fixedSize(horizontal: false, vertical: true) // Allow the text to expand vertically
                    .multilineTextAlignment(.center)
            }

            // Poll options in vertical layout
            VStack(spacing: 16) {
                ForEach(Array(inboxVM.currentFourOptions.enumerated()), id: \.element.id) { index, option in
                    if index == 0 && option.option == "a classmate" {
                        OriginalPollOptionView(option: option, isCompleted: true, isSelected: index == 0)
                            .environmentObject(pollVM)
                            .environmentObject(mainVM)
                    } else {
                        OriginalPollOptionView(option: option, isCompleted: true, isSelected: index == inboxVM.selectedVote!.votedForOptionIndex)
                            .environmentObject(pollVM)
                            .environmentObject(mainVM)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40) // Increase padding at the bottom
        }
        .background(Color.lightPurple)
    }
}

struct OriginalPollOptionView: View {
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel
    let option: PollOption
    var isCompleted: Bool = false
    var isSelected: Bool = true
    @State private var progressWidth: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 5)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )

                if pollVM.showProgress {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: progressWidth)
                        .animation(.easeInOut(duration: 0.5), value: progressWidth)
                        .cornerRadius(16)
                }

                HStack {
                    Text(option.option)
                        .foregroundColor(.black)
                        .sfPro(type: .semibold, size: .h3p1)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: pollVM.showProgress ? .leading : .center)
            }
            .onAppear {
                updateProgressWidth(geometry: geometry)
            }
            .onChange(of: pollVM.animateProgress) { _ in
                updateProgressWidth(geometry: geometry)
            }
            .onChange(of: pollVM.selectedPoll.voteSummary) { _ in
                updateProgressWidth(geometry: geometry)
            }
        }
        .frame(height: 76)
        .scaleEffect(opacity == 1 ? 1 : 0.95)
        .disabled(pollVM.showProgress)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .primaryShadow()
        .opacity(isSelected ? 1 : 0.3)
    }

    private func updateProgressWidth(geometry: GeometryProxy) {
        if pollVM.animateProgress {
            withAnimation(.easeInOut(duration: 0.5)) {
                progressWidth = geometry.size.width * progress
            }
        } else {
            progressWidth = 0
        }
    }

    private var progress: Double {
        let totalVotes = pollVM.selectedPoll.voteSummary.values.reduce(0, +)
        guard totalVotes > 0 else { return 0 }
        let optionVotes = pollVM.selectedPoll.voteSummary[option.userId] ?? 0
        return Double(optionVotes) / Double(totalVotes)
    }
}

// Extension to calculate intrinsic content size
extension View {
    func intrinsicContentSize() -> CGSize {
        let hostingController = UIHostingController(rootView: self)
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        return hostingController.view.systemLayoutSizeFitting(targetSize)
    }
}

// Create a UIViewControllerRepresentable wrapper for UIActivityViewController
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)

        // Exclude irrelevant activity types if desired
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .saveToCameraRoll,
            .print,
            .copyToPasteboard
        ]

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PollAnswerDetailView()
        .environmentObject(InboxViewModel())
        .environmentObject(MainViewModel())
        .environmentObject(PollViewModel())
}