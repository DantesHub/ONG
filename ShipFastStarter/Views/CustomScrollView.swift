struct CustomScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    @Binding var isSwiping: Bool

    init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, isSwiping: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self._isSwiping = isSwiping
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { _ in
                    isSwiping = false
                }
        )
    }
}