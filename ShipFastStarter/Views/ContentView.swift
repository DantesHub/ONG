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
                            Task {
                                await mainVM.fetchUser()
                                
                            }
                        }
                case .home:
                    HomeScreen()
                case .poll:
                    PollScreen()
                        .environmentObject(pollVM)
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
