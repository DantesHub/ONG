import SwiftUI

struct InboxScreen: View {
    @EnvironmentObject var inboxVM: InboxViewModel
    @EnvironmentObject var mainVM: MainViewModel
    
    let inboxItems = [
        InboxItem(fromUser: "a girl", aura: 500, time: "now", emoji: "👧🏼", backgroundColor: Color.pink.opacity(0.3)),
        InboxItem(fromUser: "a guy", aura: 1, time: "2m ago", emoji: "👦🏼", backgroundColor: Color.blue.opacity(0.3)),
        InboxItem(fromUser: "a girl", aura: 500, time: "yesterday", emoji: "👧🏼", backgroundColor: Color.yellow.opacity(0.3)),
        InboxItem(fromUser: "a guy", aura: 1, time: "yesterday", emoji: "👦🏼", backgroundColor: Color.orange.opacity(0.3)),
        InboxItem(fromUser: "a girl", aura: 500, time: "yesterday", emoji: "👧🏼", backgroundColor: Color.purple.opacity(0.3))
    ]
    
    var body: some View {
        Group {
            if inboxVM.tappedNotification {
                
            } else {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    VStack {
    //                    Divider()
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 24) {
                                Text("New")
                                    .font(.system(size: 22, weight: .bold))
                                    .padding(.leading, 20)
                                
                                ForEach(inboxItems.prefix(2)) { item in
                                    InboxItemView(item: item)
                                }
                                
                                Text("Past")
                                    .font(.system(size: 22, weight: .bold))
                                    .padding(.leading, 20)
                                    .padding(.top, 10)
                                
                                ForEach(inboxItems.dropFirst(2)) { item in
                                    InboxItemView(item: item)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 20)
                        }
                    }
                }
            }
        }.onAppear {
            // fetch notifications
            if let user = mainVM.currUser {
                Task {
                    await inboxVM.fetchNotifications(for: user)
                }
            }
        }
    }
}

struct InboxItem: Identifiable {
    let id = UUID()
    let fromUser: String
    let aura: Int
    let time: String
    let emoji: String
    let backgroundColor: Color
}

struct InboxItemView: View {
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
                Text(item.emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(item.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(item.backgroundColor.opacity(0.55), lineWidth: 8)
                    )
                    .cornerRadius(12)
                    .rotationEffect(.degrees(-12))
                    .padding(.leading, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("from \(item.fromUser)")
                        .sfPro(type: .bold, size: .h3p1)
                    Text("aura +\(item.aura)")
                        .sfPro(type: .medium, size: .p2)
                        .foregroundColor(Color.black.opacity(0.5))
                }
                
                Spacer()
                
                Text(item.time)
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
    }
}

struct InboxScreen_Previews: PreviewProvider {
    static var previews: some View {
        InboxScreen()
            .environmentObject(MainViewModel())
            .environmentObject(InboxViewModel())
    }
}
