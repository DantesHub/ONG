//
//  ContentView.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @StateObject var authVM = AuthViewModel()
    @StateObject var pollVM = PollViewModel()
    @StateObject var inboxVM = InboxViewModel()
    @StateObject var highschoolVM = HighSchoolViewModel()
    @StateObject var profileVM = ProfileViewModel()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showDevTestingSheet = false
    @State private var tapCount = 0
    @State private var lastTapTime = Date()

    var body: some View {
        NavigationView {
            GeometryReader { _ in
                ZStack {
                    Color(.primaryBackground).edgesIgnoringSafeArea(.all)
                    switch mainVM.currentPage {
                    case .onboarding:
                        OnboardingView()
                            .environmentObject(authVM)
                            .environmentObject(mainVM)
                            .environmentObject(pollVM)
                    case .home:
                        HomeScreen()
                    case .poll:
                        PollScreen()
                            .environmentObject(pollVM)
                    case .cooldown:
                        PollCooldownScreen()
                            .environmentObject(pollVM)
                            .environmentObject(mainVM)
                    case .inbox:
                        InboxScreen()
                            .environmentObject(mainVM)
                            .environmentObject(inboxVM)
                    case .profile:
                        ProfileScreen()
                            .environmentObject(mainVM)
                            .environmentObject(authVM)
                            .environmentObject(profileVM)

                    }
                }
                .onChange(of: mainVM.currUser) {
                    if let currUser = mainVM.currUser, mainVM.currentPage == .inbox {
                        Task {
                            await inboxVM.fetchNotifications(for: currUser)
                        }
                    }
                }
                .onAppear {
                    authVM.isUserSignedIn()
                    if UserDefaults.standard.bool(forKey: "finishedOnboarding") {
                        Task {
                            await mainVM.fetchUser()
                            if let user = mainVM.currUser {
                                pollVM.checkCooldown(user: user)
                                highschoolVM.checkHighSchoolLock(for: user)
                                
                                if let endTime = pollVM.cooldownEndTime {
                                    pollVM.completedPoll = false
                                    mainVM.currentPage = .cooldown
                                } else {
                                    fetchPolls(user: user)
                                    mainVM.currentPage = .poll
                                }
                                if user.proPic {
                                    profileVM.fetchUserProfilePicture(user: user)
                                }
                            }
                        }
                    } else {
                        
                    }
                }
                .gesture(
                    TapGesture(count: 3)
                        .onEnded { _ in
                            showDevTestingSheet = true
                        }
                )
                .sheet(isPresented: $showDevTestingSheet) {
                    DevTestingView()
                        .environmentObject(mainVM)
                        .environmentObject(pollVM)
                }
          
            }
            .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if mainVM.currentPage != .onboarding {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                Text("inbox") 
                                    .sfPro(type: .bold, size: .h3p1)
                                    .onTapGesture {
                                        withAnimation {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            Analytics.shared.log(event: "Tabbar: Tapped Inbox")
                                            mainVM.currentPage = .inbox
                                        }
                                    }.opacity(mainVM.currentPage == .inbox ? 1 : 0.3)
                                Spacer()
                                Text("play")
                                    .sfPro(type: .bold, size: .h3p1)
                                    .onTapGesture {
                                        withAnimation {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            Analytics.shared.log(event: "Tabbar: Tapped Polls")
                                            if let endTime = pollVM.cooldownEndTime {
                                                pollVM.completedPoll = false
                                                mainVM.currentPage = .cooldown
                                            } else {
                                                mainVM.currentPage = .poll
                                            }
                                        }
                                    }.opacity(mainVM.currentPage == .poll || mainVM.currentPage == .cooldown ? 1 : 0.3)
                                Spacer()
                                Text("profile")
                                    .sfPro(type: .bold, size: .h3p1)
                                    .onTapGesture {
                                        withAnimation {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            Analytics.shared.log(event: "Tabbar: Tapped Profile")
                                            mainVM.currentPage = .profile
                                        }
                                    }
                                    .opacity(mainVM.currentPage == .profile ? 1 : 0.3)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
        }
    }
    
    func fetchPolls(user: User) {
        Task {
            await pollVM.fetchPolls(for: user)
            withAnimation {
                mainVM.currentPage = .poll
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

struct DevTestingView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var pollVM: PollViewModel
    @EnvironmentObject var mainVM: MainViewModel

    var body: some View {
        NavigationView {
            List {
                Button("Reset Cooldown") {
                    // Implement test feature 1
                    let twelveHoursAgo = Date().addingTimeInterval(-12 * 60 * 60) // 12 hours before now
                    mainVM.currUser?.lastPollFinished = twelveHoursAgo
                    if let user = mainVM.currUser {
                        pollVM.resetCooldown(user: user)
                    }
                }
                Button("finish onboarding") {
                    // Implement test feature 2
                    UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
                    mainVM.currentPage = .poll
                }
                Button("Reset App State") {
                    // Implement app state reset
                }
                // Add more testing options as needed
            }
            .navigationTitle("Dev Testing")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(MainViewModel())
}
