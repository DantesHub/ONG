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

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Color(.primaryBackground).edgesIgnoringSafeArea(.all)
                switch mainVM.currentPage {
                case .onboarding:
                    OnboardingView()
                        .environmentObject(authVM)
                        .environmentObject(mainVM)
                        .onAppear {
                       
                        }
                case .home:
                    HomeScreen()
                case .poll:
                    PollScreen()
                        .environmentObject(pollVM)
                }
            }.onAppear {
                Task {
                    await mainVM.fetchUser()
                    if let user = mainVM.currUser {
                        highschoolVM.checkHighSchoolLock(for: user)
                        if !highschoolVM.isHighSchoolLocked {
                            // loadPolls
                            await pollVM.fetchPolls(for: user)
                            if pollVM.pollSet.count < 8 {
                                // create more polls
                                await pollVM.createPoll(user: user)
                            }
                        }
                    }
                }
            
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
