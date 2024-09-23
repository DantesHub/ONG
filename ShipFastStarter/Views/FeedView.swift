import SwiftUI

struct FeedView: View {
    @EnvironmentObject var feedVM: FeedViewModel
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(feedVM.feedPosts) { post in
                        FeedPostView(post: post)
                            .onAppear {
                                if post == feedVM.feedPosts.last {
                                    feedVM.fetchNextPage()
                                }
                            }
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    // This empty gesture prevents the ScrollView from capturing all drag gestures
                }
            )
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only allow horizontal dragging when at the top of the scroll view
                    if scrollOffset <= 0 && abs(gesture.translation.width) > abs(gesture.translation.height) {
                        NotificationCenter.default.post(name: .init("ContentViewDragGesture"), object: gesture)
                    }
                }
        )
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}