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
    @StateObject var highschoolVM = HighSchoolViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showDevTestingSheet = false
    @State private var tapCount = 0
    @State private var lastTapTime = Date()

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(.primaryBackground).edgesIgnoringSafeArea(.all)
                switch mainVM.currentPage {
                case .onboarding:
                    OnboardingView()
                        .environmentObject(authVM)
                        .environmentObject(mainVM)
                case .home:
                    HomeScreen()
                case .poll:
                    PollScreen()
                        .environmentObject(pollVM)
                case .cooldown:
                    PollCooldownScreen()
                        .environmentObject(pollVM)
                        .environmentObject(mainVM)
                }
            }
            .onAppear {
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
                                if !highschoolVM.isHighSchoolLocked {
                                    await pollVM.fetchPolls(for: user)
                                    if pollVM.pollSet.count < 8 {
                                        await pollVM.createPoll(user: user)
                                    }
                                }
                            }
                        }
                    }

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
}
