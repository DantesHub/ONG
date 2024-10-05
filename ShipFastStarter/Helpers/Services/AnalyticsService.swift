import Mixpanel
import Combine
//import Paywall
import SwiftUI
import SuperwallKit
import Mixpanel
import FirebaseAnalytics
import FirebaseCrashlytics

final class Analytics: ObservableObject {
    static let shared = Analytics()
    var logSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    /// Submit a single analytics event for logging from anywhere
    /// - Parameter event: analytics event to log
    /// This function uses the dedicated combine pipeline to submit analytics events. This allows per-event
    /// management of deduplication and anything else required and ensures that all events are treated equally
    /// whether they come in from a function call like this or through a pub lisher.
    func log(event: String) {
        logSubject.send(event)
    }

    /// Log a single analytics event with all appropriate analytics services
    /// - Parameter event: analytics event to log
    /// Currently submits to FirebaseAnalytics in all cases and GoogleAnalytics if not running in a simulator.
    /// This function shuold only be called from within the `logSubject` Combine subject, never directly from code.
    /// To log an event from code, use the `log(event:)` function above.
    func logActual(event: String, parameters: [String:Any] = [:]) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }
        
        #if !targetEnvironment(simulator)
//            AppsFlyerLib.shared().logEvent(event, withValues: [AFEventParamContent: "true"])
//            Paywall.track(name: event.eventName)
            // prepare activity report content.
        let eventInfo: [String: Any] = ["someKey": "someValue", "otherKey": 2]
        let eventInfoStringData = try! JSONSerialization.data(withJSONObject: eventInfo, options: [])
        guard let eventInfoString = String(data: eventInfoStringData, encoding: .utf8) else { return }
        
        let mixpanelParameters = parameters.compactMapValues { convertToMixpanelType($0) }
        // Firebase Analytics logging
        FirebaseAnalytics.Analytics.logEvent(event, parameters: parameters)
        // send the activity report
//        Firebase.Analytics.logEvent(event, parameters: parameters)
//        Amplitude.instance().logEvent(event, withEventProperties: parameters)
//        Superwall.shared.register(event: event, params: parameters)
//        AppsFlyerLib.shared().logEvent(event, withValues: parameters)
        Mixpanel.mainInstance().track(event: event, properties: mixpanelParameters)
        //facebook
//        AppEvents.shared.logEvent(AppEvents.Name("battledAnOrc"))

        print("logging, \(event)")
    
    #endif
    }

    init() {
        logSubject
            .sink { [self] event in
                logActual(event: event)
            }
            .store(in: &cancellables)
    }
    
    func identifyUser(user: User) {
        Mixpanel.mainInstance().identify(distinctId: user.id)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let properties: [String: MixpanelType] = [
            "id": user.id,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "username": user.username,
            "schoolId": user.schoolId,
            "color": user.color,
            "aura": user.aura,
            "godMode": user.godMode,
            "birthday": dateFormatter.date(from: user.birthday) ?? Date(),
            "grade": user.grade,
            "number": user.number,
            "lastPollFinished": user.lastPollFinished ?? Date(),
            "friends": user.friends,
            "invitedFriends": user.invitedFriends,
            "ogBadge": user.ogBadge,
            "gender": user.gender,
            "fcmToken": user.fcmToken,
            "proPic": user.proPic,
            "referral": user.referral,
            "crushId": user.crushId,
            "friendsStatus": user.friendsStatus,
            "friendRequests": user.friendRequests,
            "dateJoined": dateFormatter.date(from: user.dateJoined) ?? Date()
        ]
        
        Mixpanel.mainInstance().people.set(properties: properties)
        Mixpanel.mainInstance().track(event: "User Identified", properties: properties)
    }
    
    func convertToMixpanelType(_ value: Any) -> MixpanelType? {
        if let value = value as? MixpanelType {
            return value
        } else if let dict = value as? [String: Any] {
            return dict.mapValues { convertToMixpanelType($0) }
        } else if let array = value as? [Any] {
            return array.compactMap { convertToMixpanelType($0) }
        } else {
            return nil
        }
    }

    func logCrash(error: Error, additionalInfo: [String: Any]? = nil) {
        Crashlytics.crashlytics().record(error: error)
        
        if let info = additionalInfo {
            for (key, value) in info {
                Crashlytics.crashlytics().setCustomValue(value, forKey: key)
            }
        }
        
        print("Crash reported to Firebase Crashlytics: \(error.localizedDescription)")
    }

}

// MARK: - SwiftUI extensions

extension View {
    func onAppearAnalytics(event: String) -> some View {
        onAppear {
            Analytics.shared.log(event: event)
        }
    }
}
