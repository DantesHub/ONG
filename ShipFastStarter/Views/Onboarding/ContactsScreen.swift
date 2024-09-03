//
//  ContactsScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import SwiftUI
import Contacts

struct ContactsScreen: View {
    @State private var showingContactsAlert = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("app_logo") // Replace with your app's logo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .background(Color.white)
                .clipShape(Circle())
            
            Spacer()
            
            Button(action: {
                requestContactsAccess()
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Find My Friends")
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.orange)
                .cornerRadius(25)
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "lock.fill")
                Text("Gas cares intensely about your privacy.\nWe will never text or spam your contacts.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding()
        }
        .background(Color.orange)
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showingContactsAlert) {
            Alert(
                title: Text("\"Gas\" Would Like to Access Your Contacts"),
                message: Text("Your contacts are used to find friends and uploaded to a server."),
                primaryButton: .default(Text("OK"), action: {
                    // Handle OK action
                }),
                secondaryButton: .cancel(Text("Don't Allow"))
            )
        }
    }
    
    func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    // Access granted, proceed with contact access
                    print("Contacts access granted")
                } else {
                    // Access denied, show alert or handle accordingly
                    showingContactsAlert = true
                }
            }
        }
    }
}

#Preview {
    ContactsScreen()
}
