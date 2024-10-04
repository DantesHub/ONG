//
//  ColorScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/7/24.
//

import SwiftUI

struct ColorScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var pollVM: PollViewModel

    let columns = [
         GridItem(.flexible()),
         GridItem(.flexible())
     ]
    
    var body: some View {
        VStack {
            Text("finally, pick a color")
                .sfPro(type: .bold, size: .h1)
            .foregroundColor(.black)
            Text("keep this a secret 🤫")
                .sfPro(type: .medium, size: .h2)
                .foregroundColor(.gray)
            VStack {
                HStack {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(Constants.colors.indices, id: \.self) { index in
                            borderedRectangle(color: Color(Constants.colors[index]))
                                .aspectRatio(1, contentMode: .fit)
                                .onTapGesture {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation {
                                        Analytics.shared.log(event: "ColorsScreen: Tapped Color")
                                        mainVM.currUser?.color = Constants.colors[index]
                                        UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
                                        
                                        if let currUser = mainVM.currUser {
                                            Task {
                                                try await FirebaseService.shared.updateDocument(collection: FirestoreCollections.users, object: currUser)
                                                await pollVM.fetchPolls(for: currUser) 
                                                Analytics.shared.identifyUser(user: currUser)
                                            }
                                        }
                                        
                                        pollVM.isNewPollReady = true
                                        mainVM.currentPage = .cooldown
                                    }
                                }
                        }
                    }.padding()
                }
            }
        }
    }
    
    func borderedRectangle(color: Color) -> some View {
           ZStack {
               RoundedRectangle(cornerRadius: 16)
                   .fill(color) // Light green color
                   .overlay(
                       RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(1), lineWidth: 3)
                         .padding(1)
                         .mask(RoundedRectangle(cornerRadius: 16))
                   )
            }
           .frame(width: 156, height: 124) // Adjust height as needed
           .primaryShadow()
       }
}

#Preview {
    ColorScreen()
}
