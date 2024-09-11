import SwiftUI

struct InboxScreen: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

//    let inboxItems = [
//        InboxItem(fromUser: "a girl", aura: 500, time: "now", emoji: "👧🏼", backgroundColor: Color.pink.opacity(0.3)),
//        InboxItem(fromUser: "a guy", aura: 1, time: "2m ago", emoji: "👦🏼", backgroundColor: Color.blue.opacity(0.3)),
//        InboxItem(fromUser: "a girl", aura: 500, time: "yesterday", emoji: "👧🏼", backgroundColor: Color.yellow.opacity(0.3)),
//        InboxItem(fromUser: "a guy", aura: 1, time: "yesterday", emoji: "👦🏼", backgroundColor: Color.orange.opacity(0.3)),
//        InboxItem(fromUser: "a girl", aura: 500, time: "yesterday", emoji: "👧🏼", backgroundColor: Color.purple.opacity(0.3))
//    ]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
                VStack {
    //                    Divider()
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            if inboxVM.newUsersWhoVoted.isEmpty && inboxVM.oldUsersWhoVoted.isEmpty && inboxVM.friendRequests.isEmpty {
                                Spacer()
                                Text("No one has voted for you yet!\n\nTip: Answer more questions to show up in more polls")
                                    .font(.system(size: 22, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 48)
                                    .opacity(0.3)
                                    .offset(y: 64)
                                Spacer()
                            } else {
                                if !inboxVM.newUsersWhoVoted.isEmpty || !inboxVM.friendRequests.isEmpty {
                                    
                                    Text("New")
                                        .font(.system(size: 22, weight: .bold))
                                        .padding(.leading, 20)
                                }
                                    ForEach(inboxVM.friendRequests) { request in
                                        FriendRequestView(request: request)
                                    }
                                if !inboxVM.newUsersWhoVoted.isEmpty {
                                    ForEach(inboxVM.newUsersWhoVoted) { item in
                                        InboxItemView(item: item)
                                    }
                                }
                                
                                if !inboxVM.oldUsersWhoVoted.isEmpty {
                                    Text("Past")
                                        .font(.system(size: 22, weight: .bold))
                                        .padding(.leading, 20)
                                        .padding(.top, 10)
                                    
                                    ForEach(inboxVM.oldUsersWhoVoted) { item in
                                        InboxItemView(item: item)
                                    }
                                }
                            }
                         
                            Spacer()
                        }
                        .padding(.top, 20)
                    }
                }
        }
        .onAppear {
        }.sheet(isPresented: $inboxVM.tappedNotification) {
            PollAnswerDetailView()
        }.onAppearAnalytics(event: "InboxScreen: Screenload")
    }
}

struct InboxItem: Identifiable {
    let id: String
    let userId: String
    let firstName: String
    let aura: Int
    let time: Date
    let gender: String
    let grade: String
    let backgroundColor: Color
    let accompanyingPoll: Poll
    let pollOption: PollOption
    let isNew: Bool
}

struct InboxItemView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    let item: InboxItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(1), lineWidth: 4)
                        .padding(1)
                        .mask(RoundedRectangle(cornerRadius: 16))
                )
            HStack(spacing: 20) {
                Text(item.gender == "boy" ? "👦🏼" : "👧🏼")
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(item.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.15), lineWidth: 8)
                    )
                    .cornerRadius(12)
                    .rotationEffect(.degrees(-12))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("from \(item.grade)")
                        .sfPro(type: .bold, size: .h3p1)
                    Text("aura +\(item.aura)")
                        .sfPro(type: .medium, size: .p2)
                        .foregroundColor(Color.black.opacity(0.5))
                }
                
                Spacer()
                Text(inboxVM.formatRelativeTime(from: item.time))
                    .sfPro(type: .medium, size: .p2)
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 20)
        }
        .cornerRadius(16)
        .primaryShadow()
        .padding(.horizontal)
        .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                Analytics.shared.log(event: "InboxScreen: Tapped Row")
                inboxVM.selectedPoll = item.accompanyingPoll
                inboxVM.selectedPollOption = item.pollOption
                inboxVM.selectedInbox = item
                inboxVM.tappedNotificationRow()
                if item.isNew {
                    Task {
                        await inboxVM.updateViewStatus()
                    }
                }
            withAnimation {
                inboxVM.tappedNotification = true
            }
        }
    }
}

struct PollAnswerDetailView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    
    var body: some View {
        ZStack {
            Color.lightPurple.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            inboxVM.tappedNotification = false
                        }
                    Spacer()
                }.padding(32)
                Spacer()
                // Poll question
                VStack(spacing: 0) {
                    Text(inboxVM.selectedInbox?.gender == "male" ? "👦🏼" : "👧🏼")
                        .font(.system(size: 40))
                        .frame(width: 60, height: 60)
                        .background(inboxVM.selectedInbox?.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(0.2), lineWidth: 8)
                        )
                        .cornerRadius(8)
                        .rotationEffect(.degrees(-12))
                        .padding(.leading, 8)
                    Text("from a \(inboxVM.selectedInbox?.gender ?? "boy") in \(inboxVM.selectedInbox?.grade ?? "")")
                        .sfPro(type: .semibold, size: .h3p1)
                        .padding(.top)
                    Spacer()
                    Text(inboxVM.selectedPoll?.title ?? "")
                        .sfPro(type: .bold, size: .h1)
                        .frame(height: 124, alignment: .top)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                // Poll options in vertical layout
                VStack(spacing: 24) {
                    ForEach(Array(inboxVM.currentFourOptions.enumerated()), id: \.element.id) { index, option in
                        PollOptionView(option: option, isCompleted: true, isSelected: index == 0)
                    }
                }
                .padding()
            }
        }
      
    }
}

struct InboxScreen_Previews: PreviewProvider {
    static var previews: some View {
        InboxScreen()
            .environmentObject(MainViewModel())
            .environmentObject(InboxViewModel())
    }
}

struct FriendRequestView: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    var request: FriendRequest // Assuming FriendRequest is the correct type
    @State private var isPressed = false
    
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
                    ProfilePictureView(user: request.user)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(request.user.firstName) \((request.user.lastName))")
                            .sfPro(type: .bold, size: .p2)
                        Text("\(request.user.grade)")
                            .sfPro(type: .bold, size: .p2)
                            .foregroundColor(Color.black.opacity(0.5))
                    }.padding(.leading)
                    
                    Spacer()
                    VStack {
                        AcceptButton(isPressed: $isPressed) {
                            Analytics.shared.log(event: "InboxScreen: Tapped Accept")
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                mainVM.currUser?.friendRequests.removeValue(forKey: request.user.id)
                                mainVM.currUser?.friends[request.user.id] = Date().toString()

                                    if let user = mainVM.currUser {
                                        Task {
                                            await inboxVM.tappedAcceptFriendRequest(currUser: user, requestedUser: request.user)
                                        }
                                      
                                    }
                                withAnimation {
                                    inboxVM.friendRequests.removeAll { request in
                                        request.user.id ==  mainVM.currUser?.id
                                    }
                                }
                            }
                    }
                    }
                }.padding()
            }
            .cornerRadius(16)
            .primaryShadow()
            .padding(.horizontal)
        }
        // Circle X mark
        Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
            .font(.system(size: 24))
            .background(Circle().fill(Color.white))
            .offset(x: 8, y: -8)
            .position(x: UIScreen.main.bounds.width - 30, y: -105)
            .onTapGesture {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if let user = mainVM.currUser {
                        Analytics.shared.log(event: "InboxScreen: Tapped Decline")
                        mainVM.currUser?.friendRequests.removeValue(forKey: request.user.id)
                        
                        Task {
                            await inboxVM.tappedDeclineFriendRequest(currUser: user, requestedUser: request.user)
                        }
                    }
                    withAnimation {
                        inboxVM.friendRequests.removeAll { request in
                            request.user.id ==  mainVM.currUser?.id
                        }
                    }
            }
        }
}

struct ProfilePictureView: View {
    let user: User // Assuming User is the correct type
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .stroke(color: .black, width: 2)
            if !user.proPic.isEmpty {
                CachedAsyncImage(url: URL(string: user.proPic)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }.rotationEffect(.degrees(-12))
    }
}

struct AcceptButton: View {
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.isPressed = false
                    self.action()
                }
            }
        }) {
            Text("Accept")
                .sfPro(type: .bold, size: .p3)
                .foregroundColor(Color.blue)
                .frame(width: 96, height: 32)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.white)
                        Capsule()
                            .stroke(Color.black, lineWidth: 2)
                            .cornerRadius(16)
                    }
                )
                .offset(y: isPressed ? 4 : 0)
        }
        .buttonStyle(PlainButtonStyle())
        .drawingGroup()
        .shadow(color: Color.black, radius: 0, x: 0, y: isPressed ? 1 : 5)
    }
}
