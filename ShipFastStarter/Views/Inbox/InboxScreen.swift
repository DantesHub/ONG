import SwiftUI

struct InboxScreen: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Add a custom "toolbar" view
                customToolbar
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        if inboxVM.newUsersWhoVoted.isEmpty && inboxVM.oldUsersWhoVoted.isEmpty {
                            emptyStateView
                        } else {
                            newVotesSection
                            pastVotesSection
                        }
                    }
                    .padding(.top, 20)
                }
                .background(Color.white)
            }
        }
        .onAppear {
          
        }
        .fullScreenCover(isPresented: $inboxVM.tappedNotification) {
            PollAnswerDetailView()
        }
        .onAppearAnalytics(event: "InboxScreen: Screenload")
    }
    

    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("No one has voted for you yet!\n\nTip: Answer more questions to show up in more polls")
                .foregroundColor(Color.black.opacity(0.7))
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .opacity(0.3)
                .offset(y: 64)
            Spacer()
        }
    }
    
    private var newVotesSection: some View {
        Group {
            if !inboxVM.newUsersWhoVoted.isEmpty {
                Text("New!")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 20)
                    .foregroundColor(.black)
                ForEach(inboxVM.newUsersWhoVoted) { item in
                    InboxItemView(item: item)
                }
            }
        }
    }
    
    private var pastVotesSection: some View {
        Group {
            if !inboxVM.oldUsersWhoVoted.isEmpty {
                Text("Past")
                    .foregroundColor(.black)
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 20)
                    .padding(.top, 10)
                
                ForEach(inboxVM.oldUsersWhoVoted) { item in
                    InboxItemView(item: item)
                }
            }
        }
    }
    
    var customToolbar: some View {
       HStack {
           Text("")
               .sfPro(type: .bold, size: .h3p1)
               .foregroundColor(.black)
       }
       .frame(height: 1)
       .frame(maxWidth: .infinity)
       .background(Color.white)
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
    var isNew: Bool
    let shields: Int
    
    static var exInboxItem = InboxItem(id: UUID().uuidString, userId: "ongteam", firstName: "a friend", aura: 100, time: Date.longTimeAgo(), gender: "boy", grade: "ONG team", backgroundColor: Color.primaryBackground, accompanyingPoll: Poll.exPoll, pollOption: PollOption.exPollOption, isNew: true, shields: 0)
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
                            .stroke(Color.black.opacity(0.25), lineWidth: 8)
                    )
                    .cornerRadius(12)
                    .rotationEffect(.degrees(-12))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("from \(item.grade)")
                        .sfPro(type: .bold, size: .h3p1)
                        .foregroundColor(Color.black)
                    Text("aura +\(item.aura)")
                        .sfPro(type: .medium, size: .p2)
                        .foregroundColor(Color.black.opacity(0.5))
                }
                
                Spacer()
                Text(Date.formatRelativeTime(from: item.time))
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
                        if item.firstName == "ONG" {
                            UserDefaults.standard.setValue(true, forKey: Constants.sawThisInboxItem)
                        }
                        await inboxVM.updateViewStatus()
                    }
                }
            withAnimation {
                let viewedNotifcationIds: [String] = UserDefaults.standard.array(forKey: Constants.viewedNotificationIds) as? [String] ?? []
                var updatedArray = viewedNotifcationIds
                if !updatedArray.contains(where: { id in
                    id == item.accompanyingPoll.id
                }) {
                    updatedArray.append(item.accompanyingPoll.id)
                }
                
                inboxVM.tappedNotification = true
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
