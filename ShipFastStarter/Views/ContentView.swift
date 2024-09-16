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
    @Environment(\.scenePhase) private var scenePhase

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showDevTestingSheet = false
    @State private var offset: CGFloat = 0
    @State private var showSplash = true
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    
                    if showSplash {
                        SplashScreen()
                    } else if mainVM.currentPage == .onboarding {
                        if mainVM.currentPage == .onboarding {
                            OnboardingView()
                                .environmentObject(authVM)
                                .environmentObject(mainVM)
                                .environmentObject(pollVM)
                                .environmentObject(profileVM)
                                .environmentObject(highschoolVM)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    } else {
                        HStack(spacing: 0) {
                            ForEach([Page.friendRequests, Page.inbox, Page.poll, Page.profile], id: \.self) { page in
                                pageView(for: page)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                        .offset(x: -CGFloat(pageIndex(for: mainVM.currentPage)) * geometry.size.width + offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if mainVM.currentPage != .onboarding && mainVM.currentPage != .splash {
                                        offset = gesture.translation.width
                                    }
                                }
                                .onEnded { gesture in
                                    let pageWidth = geometry.size.width
                                    let dragThreshold: CGFloat = 0.25
                                    let draggedRatio = gesture.predictedEndTranslation.width / pageWidth
                                    
                                    if abs(draggedRatio) > dragThreshold {
                                        if draggedRatio > 0 {
                                            navigateRight()
                                        } else {
                                            navigateLeft()
                                        }
                                    }
                                    
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        offset = 0
                                    }
                                }
                        )
                    
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !showSplash && mainVM.currentPage != .onboarding {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            if mainVM.currentPage == .inbox || mainVM.currentPage == .friendRequests {
                                toolbarButton(for: .friendRequests, title: "add +")
                                Spacer()
                            }
                            toolbarButton(for: .inbox, title: "inbox")
                            Spacer()
                            toolbarButton(for: .poll, title: "play")
                            Spacer()
                            toolbarButton(for: .profile, title: "profile")
                        }
                        .foregroundColor(.black)
                    }
                }
            }
        }
        .onAppear {
            setupInitialState()
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    showSplash = false
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .active:
                    if mainVM.onboardingScreen == .lockedHighschool, let currUser = mainVM.currUser {
                        if !UserDefaults.standard.bool(forKey: "finishedOnboarding") {
                            Task {
                                await highschoolVM.checkHighSchoolLock(for: currUser, id: currUser.schoolId)
                                if !highschoolVM.isHighSchoolLocked {
                                    mainVM.onboardingScreen = .addFriends
                                    setupInitialState()
                                }
                            }
                        }
                    } else {
                        Task {
                            await mainVM.fetchUser()
                            if let currUser = mainVM.currUser {                                
                                await fetchUserData(currUser)
                            }
                        }
                      
                    }
                case .background:
                    break
                case .inactive:
                    break
                @unknown default:
                    break
                }
         }

    }
    
    @ViewBuilder
    private func pageView(for page: Page) -> some View {
        switch page {
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
        case .poll, .cooldown:
           if let endTime = pollVM.cooldownEndTime {
               PollCooldownScreen()
                   .environmentObject(profileVM)
                   .environmentObject(authVM)
                   .environmentObject(mainVM)
                   .environmentObject(pollVM)
            } else {
                PollScreen()
                    .environmentObject(profileVM)
                    .environmentObject(authVM)
                    .environmentObject(mainVM)
                    .environmentObject(pollVM)
            }
         
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
    
    private func toolbarButton(for page: Page, title: String) -> some View {
        Button(action: {
            withAnimation {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                Analytics.shared.log(event: "Tabbar: Tapped \(title)")
                mainVM.currentPage = page
            }
        }) {
            Text(title)
                .sfPro(type: .bold, size: .h3p1)
                .foregroundColor(.black)
                .opacity(mainVM.currentPage == page || mainVM.currentPage == .cooldown && title == "play" ? 1 : 0.3)
        }
    }
    
    private func pageIndex(for page: Page) -> Int {
        switch page {
        case .friendRequests: return 0
        case .inbox: return 1
        case .poll, .cooldown: return 2
        case .profile: return 3
        default: return 2 // Default to poll/cooldown screen
        }
    }
    
    private func navigateLeft() {
        withAnimation {
            switch mainVM.currentPage {
            case .inbox:
                if let endTime = pollVM.cooldownEndTime {
                    mainVM.currentPage = .cooldown
                } else {
                    mainVM.currentPage = .poll
                }
            case .poll, .cooldown:
                mainVM.currentPage = .profile
            case .friendRequests:
                mainVM.currentPage = .inbox
            default:
                break
            }
        }
    }
    
    private func navigateRight() {
        withAnimation {
            switch mainVM.currentPage {
            case .profile:
                if let endTime = pollVM.cooldownEndTime {
                    mainVM.currentPage = .cooldown
                } else {
                    mainVM.currentPage = .poll
                }
            case .poll, .cooldown:
                mainVM.currentPage = .inbox
            case .inbox:
                mainVM.currentPage = .friendRequests
            default:
                break
            }
        }
    }
    
    private func setupInitialState() {
        authVM.isUserSignedIn()
        
        if UserDefaults.standard.bool(forKey: "finishedOnboarding") {
            Task {
                await mainVM.fetchUser()
                
                if let user = mainVM.currUser {
                    await profileVM.fetchPeopleList(user: user)
                    await fetchUserData(user)
                    pollVM.checkCooldown(user: user)
                    
                    if pollVM.cooldownEndTime != nil {
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
    
    
    private func fetchUserData(_ user: User) async {
        async let notifications = inboxVM.fetchNotifications(for: user)
        async let peopleList = profileVM.fetchPeopleList(user: user)
        async let profilePic = profileVM.fetchUserProfilePicture(user: user)
        _ = await (notifications, peopleList, profilePic)
    }
    
    
        
    private func fetchPolls(user: User) async {
        Task {
            await pollVM.fetchPolls(for: user)
            withAnimation {
                mainVM.currentPage = .poll
            }
        }
       
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(MainViewModel())
}
