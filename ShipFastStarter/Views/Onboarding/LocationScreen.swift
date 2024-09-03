import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

struct LocationScreen: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "map.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
            
            Text("Connect your school\nto find friends")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
            
            Button(action: {
                locationManager.requestLocation()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Find My School")
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.orange)
                .cornerRadius(25)
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "lock.fill")
                Text("Gas cares intensely about your privacy.\nLocation is only used to find nearby schools.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(Color.orange)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LocationScreen()
}
