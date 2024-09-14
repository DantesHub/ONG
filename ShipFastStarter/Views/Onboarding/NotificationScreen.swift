//
//  NotificationScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/8/24.
//

import SwiftUI
import UserNotifications

struct NotificationScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @State private var showNotificationPrompt = false

    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                
                Text("ong is way more fun with notifications")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .padding(.horizontal, 36)
                    .padding(.top, 32)
                
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("“ONG” Would Like to Send You Notifications")
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                            .frame(height: 65)
                        Text("Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .frame(height: 65)
                    }.frame(height: 120)
                        .padding(.top, 4)
                        .padding(.bottom)
                    Divider()
                    
                    HStack(alignment: .center, spacing: 0) {
                        Button(action: {
                            // Handle Don’t Allow action
                            Analytics.shared.log(event: "Notifications: Tapped Don't Allow")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation {
                                mainVM.onboardingScreen = .color
                            }
                        }) {
                            Text("Don’t Allow")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .cornerRadius(10, corners: [.bottomLeft])
                        
                        Divider()
                        
                        Button(action: {
                            Analytics.shared.log(event: "Notifications: Tapped Allow")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            requestNotificationPermission()
                            
                        }) {
                            Text("Allow")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .cornerRadius(10, corners: [.bottomRight])
                    }.frame(height: 40, alignment: .center)
                    .padding(.top, 4)
                }
                .frame(height: 200)
                .background(Color(UIColor.black).opacity(0.75))
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal,  52)
                .padding(.top, 32)
                Spacer()
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted.")
                    Analytics.shared.log(event: "Notifications: Granted Permission")
                } else {
                    print("Notification permission denied.")
                    Analytics.shared.log(event: "Notifications: Denied Permission")
                }
                
            
                // Move to the next screen only if the app is in the foreground
                withAnimation {
                    mainVM.onboardingScreen = .color
                }
            }
        }
    }
}

struct NotificationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotificationScreen()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
