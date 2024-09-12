//
//  ShipFastStarterApp.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI
import SwiftData
import SwiftData
import Mixpanel
import AppsFlyerLib
import RevenueCat
import SuperwallKit
import FirebaseCore
import FirebaseAuth
import UserNotifications
import FirebaseMessaging

@main
struct ShipFastStarterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var mainVM: MainViewModel = MainViewModel()
    @StateObject var pollVM: PollViewModel = PollViewModel()
    @State private var showSplash = true

    init() {

        setup()

        
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(mainVM)
                    .environmentObject(pollVM)
                
                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    }

private extension ShipFastStarterApp {
    func setup() {
        let secondLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        
        if !secondLaunch {
            UserDefaults.standard.setValue(true, forKey: "firstLaunch")
            let userId = UUID().uuidString
            UserDefaults.standard.setValue(userId, forKey: Constants.userId)
        } else {
        
        }
        
        let userId = UserDefaults.standard.string(forKey: Constants.userId) ?? ""
        
//        Purchases.configure(withAPIKey: "", appUserID: userId)
//
//        Superwall.configure(apiKey: "pk_88a4283fb120960bd9daaf8180061db015bbeeb303396abb", purchaseController: RCPurchaseController.shared)
//        Superwall.shared.identify(userId: userId)
//
//        AppsFlyerLib.shared().appsFlyerDevKey = ""
//        AppsFlyerLib.shared().appleAppID = ""
//        AppsFlyerLib.shared().customerUserID = userId
//        AppsFlyerLib.shared().logEvent("App Started", withValues: [:])
//        AppsFlyerLib.shared().isDebug = false
//        AppsFlyerLib.shared().start()
//
        
        Mixpanel.initialize(token: "", trackAutomaticEvents: false)
        Mixpanel.mainInstance().track(event: "App Start")
        Mixpanel.mainInstance().identify(distinctId: userId)
//        UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
        UserDefaults.standard.setValue("+12012222222", forKey: "userNumber")
    }
}

//MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var mainViewModel: MainViewModel?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // App has entered the background
        print("App did enter the background")
        
        // Perform any necessary actions or save any state
        // For example, you can save user data, pause ongoing tasks, or release resources
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        //             if let error = error {
        //                 print("Error requesting notification authorization: \(error)")
        //             } else {
        //                 print("Notification authorization granted: \(granted)")
        //             }
        //         }
        print("didFinishLaunchingWithOptions")
        // Check if the app was launched from a local notification
        //        if let notificationResponse = launchOptions?[.not] as? UNNotificationResponse {
        //                 let userInfo = notificationResponse.notification.request.content.userInfo
        //            if let deepLink = userInfo["deepLink"] as? String {
        //                        // Handle the deep link here
        //                        print("App launched from local notification with Deep Link: \(deepLink)")
        //                        // You can pass the deep link to your SwiftUI views using an environment object or other means
        //                    }
        //             }
        
        application.registerForRemoteNotifications()
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//        UNUserNotificationCenter.current().requestAuthorization(
//          options: authOptions,
//          completionHandler: { _, _ in }
//        )

        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Notification received while app is in the foreground.")
        completionHandler([.alert, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Handle the remote notification, which may include Firebase Cloud Messaging data.
        print("got remote notification man lets go")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle any registration errors here.
        print("failed to get remote notification man lets go", error.localizedDescription)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            true
        }else {
            false
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("token",deviceToken.toJsonString())
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
          if let token = fcmToken {
              print("FCM Token: \(token)")
              // Save or use the FCM token as needed
              UserDefaults.standard.setValue(token, forKey: "fcmToken")
//              Task {
//                  var user = User.exUser
//                  user.number = "2234567890"
//                  user.firstName = "Epik"
//                  user.fcmToken = token
//                  try await FirebaseService.shared.updateDocument(collection: "users", field: "number", isEqualTo: "2234567890", object: user)
//              }
          }
      }

//   
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        print("hello")
    }

    
}
