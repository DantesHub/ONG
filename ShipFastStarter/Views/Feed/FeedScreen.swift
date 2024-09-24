import SwiftUI

struct FeedScreen: View {
    @EnvironmentObject var feedVM: FeedViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var displayTutorial = false
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                InboxScreen().customToolbar
             
                if feedVM.feedPosts.isEmpty {
                    Text("gotta get some friends!")
                        .foregroundColor(Color.black.opacity(0.7))
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: UIScreen.size.width)
                        .padding(.horizontal, 32)
                        .opacity(0.3)
                        .padding(.top, 32)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 32) {
                            ForEach(sortedGroupKeys, id: \.self) { key in
                                Section(header: sectionHeader(for: key)) {
                                    ForEach(groupedFeedPosts[key] ?? []) { post in
                                        ZStack {
                                            FeedPostRow(post: post)
                                                .padding(.horizontal)
                                                .onTapGesture {
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    withAnimation {
                                                        Analytics.shared.log(event: "FeedScreen: Tapped Row")
                                                        profileVM.visitedUser = post.user
                                                        profileVM.isVisitingUser = true
                                                    }
                                                }
                                            Text("\(post.aura)")
                                                .foregroundColor(.white)
                                                .sfPro(type: post.aura <= 50 ? .regular : post.aura <= 125  ? .medium : post.aura <= 200 ? .semibold : .bold, size: post.aura <= 50 ? .h1Small : post.aura <= 125  ? .h1 : post.aura <= 200 ? .h1Big : .title)
                                                .stroke(color: post.aura <= 50 ? .black : post.aura <= 125  ? .red : post.aura <= 200 ? Color("pink") : Color("primaryBackground"), width: 3)
                                                .shadow(color: .black.opacity(0.5), radius: 4)
                                                .rotationEffect(.degrees(16))
                                                .padding(8)
                                                .cornerRadius(8)
                                                .position(x: UIScreen.main.bounds.width / (post.aura > 200 ? 1.2 :  1.14), y: 12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.onAppear {
            if !UserDefaults.standard.bool(forKey: Constants.finishedFeedTutorial) && mainVM.currentPage == .feed {
                displayTutorial = true
            }
        }.onChange(of: mainVM.currentPage) {
            if !UserDefaults.standard.bool(forKey: Constants.finishedFeedTutorial) && mainVM.currentPage == .feed {
                displayTutorial = true
            }
        }
        .sheet(isPresented: $displayTutorial) {
            TutorialModal(isPresented: $displayTutorial, isFeed: true)
        }
    }
    
    var groupedFeedPosts: [String: [FeedPost]] {
        let calendar = Calendar.current
        let now = Date()
        
        return Dictionary(grouping: feedVM.feedPosts) { post in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: post.timestamp, to: now)
            
            if let year = components.year, year > 0 {
                return "Past"
            }
            
            if let month = components.month, month > 0 {
                return "Past"
            }
            
            if let day = components.day, day > 0 {
                if day == 1 {
                    return "Yesterday"
                } else if day < 7 {
                    return "This Week"
                } else {
                    return "Past"
                }
            }
            
            // Everything within the last 24 hours is considered "Today"
            return "Today"
        }
    }
    
    var sortedGroupKeys: [String] {
        let order = ["Today", "Yesterday", "This Week", "Past"]
        return order.filter { groupedFeedPosts.keys.contains($0) }
    }
    
    func sectionHeader(for key: String) -> some View {
        Text(key)
            .foregroundColor(.black)
            .sfPro(type: .bold, size: .h2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .padding(.top, 12)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct FeedPostRow: View {
    @EnvironmentObject var feedVM: InboxViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var mainVM: MainViewModel
    let post: FeedPost
    @State private var isPressed = false
    @State private var showCheck = false

    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(1), lineWidth: 4)
                            .padding(1)
                            .mask(RoundedRectangle(cornerRadius: 16))
                    )
                HStack {
                    ZStack {
                        ProfilePictureView(user: post.user)
                        Text(post.votedByUser.gender == "boy" ? "👦🏼" : "👧🏼")
                            .font(.system(size: 14))
                            .frame(width: 28, height: 28)
                            .background(Color(post.votedByUser.color))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black.opacity(0.25), lineWidth: 4)
                            )
                            .cornerRadius(4)
                            .rotationEffect(.degrees(-8))
                            .offset(x: 24, y: 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(post.question)")
                            .sfPro(type: .bold, size: .p2)
                            .foregroundColor(Color.black)
                        Text("from someone in \(post.votedByUser.grade)")
                            .sfPro(type: .medium, size: .p3)
                            .foregroundColor(Color.black.opacity(0.5))
                    }.padding(.leading)
                    
                    Spacer()
                    Text(Date.formatRelativeTime(from: post.timestamp))
                        .sfPro(type: .medium, size: .p3)
                        .foregroundColor(.gray)
                }.padding(24)
       
            }
            .cornerRadius(16)
            .primaryShadow()
        }
    }
}
