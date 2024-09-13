import SwiftUI

struct InviteFriendsModal: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var isShareSheetPresented = false

    var body: some View {
        ZStack {
          
                Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                // Title
                Text("invite friends from buildspace")
                    .sfPro(type: .bold, size: .h3)
                    .foregroundColor(.white) 
                if mainVM.currentPage == .friendRequests {
//                    Color.white.edgesIgnoringSafeArea(.all)
                } else {
                    // Subtitle
                    Text("5 more needed to unlock")
                        .sfPro(type: .medium, size: .p2)
                        .foregroundColor(.white.opacity(0.9))
                }
           
                
                // Buttons
                HStack(spacing: 16) {
                    // Snapchat Button
                    Button(action: {
                        // Action for Snapchat button
                    }) {
                        HStack {
                            Image("scLogo") // Replace with Snapchat icon
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 64, height: 64)
                                .foregroundColor(.black)
                        }
                        .frame(width: UIScreen.size.width * 0.375, height: 60)
                        .background(Color(hex: "FFFF00"))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                    }
                    
                    // Instagram Button
                    Button(action: {
                        // Action for Instagram button
                    }) {
                        HStack {
                            Image("instaLogo") // Replace with Instagram icon
                                .resizable()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white)
                        }
                        .frame(width: UIScreen.size.width * 0.375, height: 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink, .orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                    }
                }.padding(12)
                .padding(.top)
                // Share on Messages Button
           
                if let url = URL(string: "https://apps.apple.com/app/apple-store/id6478835459") {
                    ShareLink(item: url, subject: Text("Get Your Colors"), message: Text("Join me on WhatColors and see what colors look best on you. Sign up with my invite code")) {
                        Text("share on messages")
                            .sfPro(type: .bold, size: .h3p1)
                            .foregroundColor(.white)
                            .frame(width: UIScreen.size.width * 0.8, height: 60)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "5BF675"), Color(hex: "0CBD2A")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(17)
                            .padding(.horizontal)
                    }.simultaneousGesture(TapGesture().onEnded() {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        Analytics.shared.log(event: "InviteModal: Tapped Share")
                    })
                }
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: ["Check out this cool app!"])
        }
    }
}

// Add this struct at the bottom of the file
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct InviteFriendsModal_Previews: PreviewProvider {
    static var previews: some View {
        InviteFriendsModal()
            .environmentObject(MainViewModel())
    }
}
