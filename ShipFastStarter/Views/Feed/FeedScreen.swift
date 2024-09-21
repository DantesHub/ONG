import SwiftUI

struct FeedScreen: View {
    @EnvironmentObject var feedVM: FeedViewModel
    @EnvironmentObject var mainVM: MainViewModel

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
//                    Text("Today")
//                        .foregroundColor(.black)
//                        .font(.system(size: 22, weight: .bold))
//                        .padding(.leading, 20)
//                        .padding(.top, 10)
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 32) {
                            ForEach(feedVM.feedPosts) { post in
                                ZStack {
                                    FeedPostRow(post: post)
                                        .onAppear {
                                            if post == feedVM.feedPosts.last {
                                                feedVM.fetchNextPage()
                                            }
                                        }
                                        .padding(.horizontal)
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
                        }.padding(.top, 32)
                    }
                }
              
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FeedPostView: View {
    let post: FeedPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImage(url: URL(string: post.user.proPic)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(post.user.username)
                        .font(.headline)
                    Text(post.question)
                        .font(.subheadline)
                }
            }
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(Color(post.votedByUser.color))
                Text(post.votedByUser.username)
                Image(systemName: post.votedByUser.gender == "Male" ? "person.fill" : "person.fill")
                    .foregroundColor(.blue)
            }
            .font(.caption)
            .padding(8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
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
