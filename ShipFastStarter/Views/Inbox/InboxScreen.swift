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
            if let user = mainVM.currUser {
                Task {
                    await inboxVM.fetchNotifications(for: user)
                }
            }
        }
        .sheet(isPresented: $inboxVM.tappedNotification) {
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
                Text("New")
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
                    Text(inboxVM.selectedInbox?.gender == "boy" ? "👦🏼" : "👧🏼")
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
                        OriginalPollOptionView(option: option, isCompleted: true, isSelected: index == 0)
                    }
                }
                .padding()
            }
        }
      
    }
    
    struct OriginalPollOptionView: View {
        @EnvironmentObject var pollVM: PollViewModel
        @EnvironmentObject var mainVM: MainViewModel
        let option: PollOption
        var isCompleted: Bool = false
        var isSelected: Bool = true
        @State private var progressWidth: CGFloat = 0
        @State private var opacity: Double = 1
        
        var body: some View {
            Button(action: {
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                self.opacity = 0.7
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    withAnimation(.spring()) {
//                        self.opacity = 1
//                        if let user = mainVM.currUser {
//                            Task {
//                                await pollVM.answerPoll(user: user, option: option)
//                                print("Answer poll completed")
//                            }
//                        }
//                    }
//                }
            }) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(1), lineWidth: 5)
                                    .padding(1)
                                    .mask(RoundedRectangle(cornerRadius: 16))
                            )
                        if pollVM.showProgress {
                            Rectangle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: progressWidth)
                                .animation(.easeInOut(duration: 0.5), value: progressWidth)
                                .cornerRadius(16)
                        }
                        
                        HStack {
                            Text(option.option)
                                .foregroundColor(.black)
                                .sfPro(type: .semibold, size: .h3p1)
                            
    //                        if pollVM.showProgress {
    //                            Spacer()
    //                            Text("\(Int(progress * 100))%")
    //                                .foregroundColor(.black)
    //                                .sfPro(type: .semibold, size: .h3p1)
    //                        }
                        }
                        .padding(.horizontal, 32)
                        .frame(maxWidth: .infinity, alignment: pollVM.showProgress ? .leading : .center)
                    }
                    .onChange(of: pollVM.animateProgress) {
                        updateProgressWidth(geometry: geometry)
                    }
                    .onChange(of: pollVM.totalVotes) {
                        updateProgressWidth(geometry: geometry)
                    }
                    .onChange(of: pollVM.selectedPoll) { _ in
                        updateProgressWidth(geometry: geometry)
                    }
                }
            }
            .frame(height: 76)
            .scaleEffect(opacity == 1 ? 1 : 0.95)
            .disabled(pollVM.showProgress)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .primaryShadow()
            .opacity(isSelected ? 1 : 0.3)
        }
        
        private func updateProgressWidth(geometry: GeometryProxy) {
            if pollVM.animateProgress {
                withAnimation(.easeInOut(duration: 0.5)) {
                    progressWidth = geometry.size.width * progress
                }
            } else {
                progressWidth = 0
            }
        }
        
        private var progress: Double {
            guard pollVM.totalVotes > 0 else { return 0 }
            let optionVotes = calculateOptionVotes()
            let progress = Double(optionVotes) / Double(pollVM.totalVotes)
            return progress
        }
        
        private func calculateOptionVotes() -> Int {
            return pollVM.selectedPoll.pollOptions
                .first(where: { $0.id == option.id })?
                .votes?
                .values
                .reduce(0) { $0 + (Int($1["numVotes"] ?? "0") ?? 0) } ?? 0
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
