//
//  HighSchoolScreen.swift
//  ONG
//
//  Created by Dante Kim on 9/2/24.
//

import Foundation
import SwiftUI

struct HighSchoolScreen: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var viewModel: HighSchoolViewModel
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            Color.primaryBackground.edgesIgnoringSafeArea(.all)
            VStack {
//                SearchBar(text: $viewModel.searchQuery)
//                    .focused($isSearchFocused)
                Text("pick your highschool")
                    .sfPro(type: .bold, size: .h1)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 32)
//                Text("keep this a secret 🤫")
//                    .sfPro(type: .medium, size: .h2)
//                    .foregroundColor(.white)
//                List(viewModel.schools) { school in
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(school.name)
//                            .font(.headline)
//                        Text("\(school.city), \(school.state)")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    .padding(.vertical, 8)
//                }
//                .listStyle(PlainListStyle())
                HighschoolButton(title: "Buildspace", totalNum: 4) {
                    withAnimation {
                        mainVM.currUser?.schoolId = "buildspace"
                        if let currUser = mainVM.currUser {
                            Task {
                                await viewModel.checkHighSchoolLock(for: currUser)
                                if viewModel.isHighSchoolLocked {
                                    withAnimation {
                                        mainVM.onboardingScreen = .lockedHighschool
                                    }
                                } else {
                                    withAnimation {
                                        mainVM.onboardingScreen = .addFriends
                                    }
                                }
                            }
                        }
                    }
                }
                .environmentObject(mainVM)
                HighschoolButton(title: "Test Highschool", totalNum: viewModel.totalKids) {
                    withAnimation {
                        mainVM.currUser?.schoolId = "123e4567-e89b-12d3-a456-426614174000"
                        mainVM.onboardingScreen = .addFriends
                    }
                }
                .environmentObject(mainVM)
                .padding(.top)
                Spacer()
            }
        }
        .onAppear {
       
            isSearchFocused = true
        }
    }
}

struct HighschoolButton: View {
    @EnvironmentObject var mainVM: MainViewModel
    let title: String
    let totalNum: Int
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geometry in
                  ZStack {
                      RoundedRectangle(cornerRadius: 16)
                          .fill(Color.white)
                          .overlay(
                              RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(1), lineWidth: 5)
                                  .padding(1)
                                  .mask(RoundedRectangle(cornerRadius: 16))
                          )
                      
                      HStack {
                          Image(title == "Buildspace" ? "bsLogo" : "scLogo")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(width: 80, height: 80)
                          VStack(alignment: .leading) {
                              Text(title)
                                  .foregroundColor(.black)
                                  .sfPro(type: .bold, size: .h2)
//                              Text("\(totalNum) students")
//                                  .foregroundColor(.black.opacity(0.5))
//                                  .sfPro(type: .bold, size: .h3p1)
                          }
                       
                          Spacer()
                      }
                      .padding(.horizontal, 32)
                  }
                  .frame(height: 132)
//                  .scaleEffect(isPressed ? 0.95 : 1)
                  .onTapGesture {
                      withAnimation {
                          UIImpactFeedbackGenerator(style: .light).impactOccurred()
                          isPressed = true
                          DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                              isPressed = false
                          }
                          action()
                      }
                  }
              }
              .frame(height: 132)
              .padding(.horizontal)
              .drawingGroup()
              .offset(y: isPressed ? 2 : 0)
              .shadow(color: Color.black, radius: 0, x: 0, y: isPressed ? 1.5 : 6)
              .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search for schools", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}

struct HighSchoolScreen_Previews: PreviewProvider {
    static var previews: some View {
        HighSchoolScreen()
            .environmentObject(MainViewModel())
    }
}
