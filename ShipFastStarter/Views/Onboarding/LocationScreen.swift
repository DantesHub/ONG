import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var accuracyAuthorization: CLAccuracyAuthorization?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        accuracyAuthorization = manager.accuracyAuthorization
    }
    
    func requestTemporaryFullAccuracyAuthorization(purposeKey: String) {
        locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
    }
}

struct LocationScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Text("how it works")
                .sfPro(type: .bold, size: .h1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 56)
            Spacer()
            VStack(alignment: .leading, spacing: 24){
                Text("1.  join your school 🏫")
                    .sfPro(type: .bold, size: .h2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("2.  find friends 🫶")
                    .sfPro(type: .bold, size: .h2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("3.  answer questions\nand earn aura ✨")
                    .sfPro(type: .bold, size: .h2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            HStack {
                Image(systemName: "lock.fill")
                Text("ONG cares intensely about your privacy.\nLocation is only used to find nearby schools.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding()
            SharedComponents.PrimaryButton(
                title: "Continue",
                action: {
                    locationManager.requestLocation()
                    Analytics.shared.log(event: "LocationScreen: Tapped Continue")
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 56)
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: locationManager.authorizationStatus) { status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                handleLocationAuthorization()
            } else if status == .denied || status == .restricted {
                // Handle denied or restricted access
                print("Location access denied or restricted")
                // You might want to show an alert or navigate to a different screen
                withAnimation {
                    mainVM.onboardingScreen = .name // Navigate to the next screen even if denied
                }
            }
        }
    }
    
    private func handleLocationAuthorization() {
        switch locationManager.accuracyAuthorization {
        case .fullAccuracy:
            print("Full accuracy granted")
           withAnimation {
                mainVM.onboardingScreen = .name // Navigate to the next screen
            }
        case .reducedAccuracy:
            locationManager.requestTemporaryFullAccuracyAuthorization(purposeKey: "FindNearbySchools")
            // You might want to wait for the result of this request before navigating
            withAnimation {
                mainVM.onboardingScreen = .name // Navigate to the next screen
            }
        case .none:
            print("Accuracy authorization not determined")
        @unknown default:
            print("Unknown accuracy authorization")
        }
    }
}

#Preview {
    ZStack {
        Color.primaryBackground.edgesIgnoringSafeArea(.all)
        LocationScreen()
    }
    .environmentObject(MainViewModel())
}
