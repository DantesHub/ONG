//
//  ContentView.swift
//  ShipFastStarter
//
//  Created by Dante Kim on 6/20/24.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var highschoolVM: HighSchoolViewModel
    @StateObject var authVM = AuthViewModel()
    @StateObject var pollVM = PollViewModel()
    @StateObject var inboxVM = InboxViewModel()
    @StateObject var profileVM = ProfileViewModel()
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showDevTestingSheet = false
    @State private var tapCount = 0
    @State private var lastTapTime = Date()
    @State private var offset: CGFloat = 0
    @State private var swipeDirection: SwipeDirection = .none

    enum SwipeDirection {
        case left, right, none
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
//                    Color(.primaryBackground).edgesIgnoringSafeArea(.all)
                    switch mainVM.currentPage {
                    case .splash:
                        SplashScreen()
                    case .onboarding:
                        OnboardingView()
                            .environmentObject(authVM)
                            .environmentObject(mainVM)
                            .environmentObject(pollVM)
                            .environmentObject(profileVM)
                            .environmentObject(highschoolVM)
                    case .home:
                        HomeScreen()
                    case .poll:
                        PeopleScreen()
                            .environmentObject(profileVM)
                            .environmentObject(authVM)
                            .environmentObject(mainVM)
                            .environmentObject(pollVM)
                    case .cooldown:
                        PollCooldownScreen()
                            .environmentObject(pollVM)
                            .environmentObject(mainVM)
                    case .inbox:
                        InboxScreen()
                            .environmentObject(mainVM)
                            .environmentObject(inboxVM)
                            .environmentObject(profileVM)
                    case .profile:
                        ProfileScreen()
                            .environmentObject(mainVM)
                            .environmentObject(authVM)
                            .environmentObject(profileVM)
                    case .friendRequests:
                        FriendRequests()
                            .environmentObject(profileVM)
                            .environmentObject(inboxVM)

                    }
                }
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if mainVM.currentPage != .onboarding && mainVM.currentPage != .splash {
                                offset = gesture.translation.width
                                swipeDirection = offset > 0 ? .right : .left
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                if abs(offset) > geometry.size.width * 0.25 {
                                    switch swipeDirection {
                                    case .left:
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        navigateLeft()
                                    case .right:
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        navigateRight()
                                    case .none:
                                        break
                                    }
                                }
                                offset = 0
                                swipeDirection = .none
                            }
                        }
                )
                .onChange(of: mainVM.currUser) { newUser in
                    if let user = newUser, mainVM.currentPage == .inbox {
                        Task {
                            await fetchUserData(user)
                        }
                    }
                }
                .onAppear {
                    authVM.isUserSignedIn()
              
                    
                    if UserDefaults.standard.bool(forKey: "finishedOnboarding") {
                        Task {
                            await mainVM.fetchUser()
                            
                            if let user = mainVM.currUser {
                                await profileVM.fetchPeopleList(user: user)
                                await fetchUserData(user)
                                pollVM.checkCooldown(user: user)
                                await highschoolVM.checkHighSchoolLock(for: user)
                                
                                if let endTime = pollVM.cooldownEndTime {
                                    pollVM.completedPoll = false
                                    mainVM.currentPage = .cooldown
                                } else {
                                    await fetchPolls(user: user)
                                }
                            }
                        }
                    } else {
                        mainVM.currentPage = .onboarding
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
                    if mainVM.currentPage != .onboarding && mainVM.currentPage != .splash {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                if mainVM.currentPage == .friendRequests {
                                    Spacer()
                                }
                                if mainVM.currentPage == .inbox || mainVM.currentPage == .friendRequests {
                                    Text("add +")
                                        .sfPro(type: .bold, size: .h3p1)
                                        .onTapGesture {
                                            withAnimation {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                Analytics.shared.log(event: "Tabbar: Tapped Inbox")
                                                mainVM.currentPage = .friendRequests
                                            }
                                        }.opacity(mainVM.currentPage == .friendRequests ? 1 : 0.3)
                                    Spacer()
                                }
                                if mainVM.currentPage != .profile {
                                    Text("inbox")
                                        .sfPro(type: .bold, size: .h3p1)
                                        .onTapGesture {
                                            withAnimation {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                Analytics.shared.log(event: "Tabbar: Tapped Inbox")
                                                mainVM.currentPage = .inbox
                                            }
                                        }.opacity(mainVM.currentPage == .inbox ? 1 : 0.3)
                                }
                                
                                if mainVM.currentPage != .friendRequests {
                                    if mainVM.currentPage != .profile {
                                        Spacer()
                                    }
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
                                }
                     
                                if mainVM.currentPage != .inbox && mainVM.currentPage != .friendRequests {
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
                                    if mainVM.currentPage == .profile {
                                        Spacer()
                                    }
                                }
                              
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
        }
    }
    
    private func navigateLeft() {
        switch mainVM.currentPage {
        case .inbox:
            if let endTime = pollVM.cooldownEndTime {
                pollVM.completedPoll = false
                mainVM.currentPage = .cooldown
            } else {
                mainVM.currentPage = .poll
            }
        case .poll:
            mainVM.currentPage = .profile
        case .cooldown:
            mainVM.currentPage = .profile
        case .profile:
            break
        case .friendRequests:
            mainVM.currentPage = .inbox
        default:
            break
        }
    }
    
    private func navigateRight() {
        switch mainVM.currentPage {
        case .inbox:
            mainVM.currentPage = .friendRequests
        case .poll:
            mainVM.currentPage = .inbox
        case .profile:
            if let endTime = pollVM.cooldownEndTime {
                pollVM.completedPoll = false
                mainVM.currentPage = .cooldown
            } else {
                mainVM.currentPage = .poll
            }
        case .cooldown:
            mainVM.currentPage = .inbox
        default:
            break
        }
    }
    
    private func fetchUserData(_ user: User) async {
        async let notifications = inboxVM.fetchNotifications(for: user)
        async let peopleList = profileVM.fetchPeopleList(user: user)
//        do {
//            try await FirebaseService.shared.updateAllObjects(collection: "users")
//
//        } catch {
//            print(error.localizedDescription)
//        }

        // Wait for both tasks to complete
        _ = await (notifications, peopleList)
    }
    
    private func fetchPolls(user: User) async {
        await pollVM.fetchPolls(for: user)
        withAnimation {
            mainVM.currentPage = .poll
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
                    let sixHoursAgo = Date().addingTimeInterval(-6 * 60 * 60)
                    mainVM.currUser?.lastPollFinished = sixHoursAgo
                    if let user = mainVM.currUser {
                        pollVM.resetCooldown(user: user)
                        mainVM.currentPage = .poll
                    }
                }
                Button("switch highschool") {
                    UserDefaults.standard.setValue(true, forKey: "finishedOnboarding")
                    mainVM.onboardingScreen = .highschool
                    mainVM.currentPage = .onboarding
                }
                Button("Reset App State") {
                    resetAppState()
                }
                // Add more testing options as needed
            }
            .navigationTitle("Dev Testing")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func resetAppState() {
        // Reset all UserDefaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // Sign out of Firebase
        do {
            try Auth.auth().signOut()
            print("Successfully signed out of Firebase")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        // Reset MainViewModel state
        mainVM.currUser = nil
        mainVM.currentPage = .onboarding
        mainVM.onboardingScreen = .first
        
        // Reset PollViewModel state
        pollVM.resetState()
        
        // You might want to reset other ViewModels as well
        
        print("App state has been reset")
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(MainViewModel())
}
