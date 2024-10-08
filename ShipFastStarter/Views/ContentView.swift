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
    @StateObject var feedVM = FeedViewModel()
    @Environment(\.scenePhase) private var scenePhase

    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var showDevTestingSheet = false
    @State private var offset: CGFloat = 0
    @State private var showSplash = true
    @State private var dragGesture: DragGesture.Value?
    

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
                                .environmentObject(inboxVM)
                                .environmentObject(highschoolVM)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    } else {
                        HStack(spacing: 0) {
                            ForEach([Page.friendRequests, Page.inbox, Page.feed, Page.poll, Page.profile], id: \.self) { page in
                                pageView(for: page)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                        }
                        .offset(x: -CGFloat(pageIndex(for: mainVM.currentPage)) * geometry.size.width + offset)
                        .contentShape(Rectangle())  // Add this line
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
                        .animation(.easeInOut, value: mainVM.currentPage)  // Add this line
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
                            toolbarButton(for: .feed, title: "feed")
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
        .sheet(isPresented: $profileVM.isVisitingUser) {
            ProfileScreen()
                .environmentObject(mainVM)
                .environmentObject(authVM)
                .environmentObject(profileVM)
                .environmentObject(inboxVM)
                .environmentObject(feedVM)
        }
        .onAppear {
            setupInitialState()
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
                    cameBackFromBackground()
                case .background: break
                case .inactive:   break
                @unknown default: break
                }
         }
        .onReceive(NotificationCenter.default.publisher(for: .init("ContentViewDragGesture"))) { notification in
            if let gesture = notification.object as? DragGesture.Value {
                self.dragGesture = gesture
                handleDragGesture(gesture)
            }
        }

    }
    
    
    //MARK: - data logic
    private func setupInitialState() {
//        UserDefaults.standard.setValue(0, forKey: Constants.currentIndex)
        authVM.isUserSignedIn()
        
      
        if UserDefaults.standard.bool(forKey: "finishedOnboarding") {
            Task {
                await mainVM.fetchUser()
//
                if let user = mainVM.currUser {
                    await fetchPeopleAndNotifications(user)
                    await fetchPolls()
                    showSplash = false
                    mainVM.currentPage = .cooldown
                }
            }
        } else {
            showSplash = false
            mainVM.currentPage = .onboarding
            if UserDefaults.standard.bool(forKey: "sawLockedHighschool") {
                lockedHighschoolLogic()
            }
        }
    }
    
    func cameBackFromBackground() {
        // lockedhighschool logic
        if UserDefaults.standard.bool(forKey: "sawLockedHighschool") &&  !UserDefaults.standard.bool(forKey: "finishedOnboarding") {
           lockedHighschoolLogic()
        } else {
            // simply fetch user  again
            fetchUserAndData()
            if let user = mainVM.currUser {
                Task {
                    await fetchPolls()
                }
                if pollVM.cooldownEndTime == nil {
                    pollVM.isNewPollReady = true
                   
                }
                showSplash = false
            }
        }

    }
    
    func lockedHighschoolLogic() {
        mainVM.currentPage = .onboarding
        mainVM.onboardingScreen = .lockedHighschool
        if let currUser = mainVM.currUser {
            Task {
                fetchUserAndData()
                await highschoolVM.checkHighSchoolLock(for: currUser, id: currUser.schoolId)
                showSplash = false
                if !highschoolVM.isHighSchoolLocked {
                    mainVM.onboardingScreen = .addFriends
                    await fetchPolls()
                }
            }
        }
    }
    
    func fetchUserAndData() {
        Task {
            await mainVM.fetchUser()
            if let currUser = mainVM.currUser {
                await fetchPeopleAndNotifications(currUser)
            }
        }
    }
    

    
    private func fetchPeopleAndNotifications(_ user: User) async {
        async let profilePic = profileVM.fetchUserProfilePicture(user: user)
        _ = await (profilePic)
    }
    
    
        
    private func fetchPolls() async {
        if let user = mainVM.currUser {
            Task {
                await profileVM.fetchPeopleList(user: user)
                
                // pollVM data fetch
                pollVM.entireSchool = profileVM.peopleList
                pollVM.friends = profileVM.friends
                print(pollVM.allPolls.count, "kurapika")
                await pollVM.fetchPolls(for: user)
                print(pollVM.allPolls.count, "kurapik2")
                pollVM.checkCooldown(user: user)
                
                withAnimation {
                    if pollVM.cooldownEndTime == nil {
                        pollVM.completedPoll = false
                        pollVM.isNewPollReady = true
                    }
               
                }
                
                // feedVM data fetch
                feedVM.currUser = user
                feedVM.allUsers = profileVM.peopleList
                feedVM.allFriends = profileVM.friends
                feedVM.allPolls = pollVM.allPolls
                feedVM.fetchNextPage()
                
                // inboxVM data fetch
                inboxVM.currUser = user
                inboxVM.allUsers = profileVM.peopleList
                inboxVM.allPolls = pollVM.allPolls
                inboxVM.fetchNotifications(for: user)
            }
        }
       
    }
    
    //MARK: - Navigation
    @ViewBuilder
    private func pageView(for page: Page) -> some View {
        switch page {
        case .splash:
            SplashScreen()
        case .feed:
            FeedScreen()
                .environmentObject(feedVM)
                .environmentObject(mainVM)
                .environmentObject(profileVM)
        case .onboarding:
            OnboardingView()
                .environmentObject(authVM)
                .environmentObject(mainVM)
                .environmentObject(pollVM)
                .environmentObject(profileVM)
                .environmentObject(highschoolVM)
                .environmentObject(inboxVM)
        case .home:
            HomeScreen()
        case .poll, .cooldown:
            if pollVM.cooldownEndTime != nil || pollVM.isNewPollReady {
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
                .environmentObject(inboxVM)
                .environmentObject(feedVM)
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
                if page == .poll {
                    if let _ = pollVM.cooldownEndTime {
                        pollVM.completedPoll = false
                        mainVM.currentPage = .cooldown
                    } else {
                        mainVM.currentPage = .poll
                    }
                }
            }
        }) {
            Text(title)
                .sfPro(type: .bold, size: .h3p1)
                .foregroundColor(getButtonColor(for: page, title: title))
                .opacity(getButtonOpacity(for: page, title: title))
        }
    }
    
    private func getButtonColor(for page: Page, title: String) -> Color {
        if mainVM.currentPage == .cooldown {
            return .white
        } else {
            return .black
        }
    }
    
    private func getButtonOpacity(for page: Page, title: String) -> Double {
        if mainVM.currentPage == page || (mainVM.currentPage == .cooldown && title == "play") {
            return 1.0
        } else {
            return 0.3
        }
    }
    
    private func pageIndex(for page: Page) -> Int {
        switch page {
        case .friendRequests: return 0
        case .inbox: return 1
        case .feed: return 2
        case .poll, .cooldown: return 3
        case .profile: return 4
        default: return 2 // Default to feed screen
        }
    }
    
    private func navigateLeft() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            switch mainVM.currentPage {
            case .inbox:
                mainVM.currentPage = .feed
            case .feed:
                if let _ = pollVM.cooldownEndTime {
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
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation {
            switch mainVM.currentPage {
            case .profile:
                if let _ = pollVM.cooldownEndTime {
                    mainVM.currentPage = .cooldown
                } else {
                    mainVM.currentPage = .poll
                }
            case .inbox:
                mainVM.currentPage = .friendRequests
            case .feed:
                mainVM.currentPage = .inbox
            case .poll, .cooldown:
                mainVM.currentPage = .feed            
            default:
                break
            }
        }
    }
    
    private func handleDragGesture(_ gesture: DragGesture.Value) {
        offset = gesture.translation.width
        
        let pageWidth = UIScreen.main.bounds.width
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
}



#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(MainViewModel())
}
