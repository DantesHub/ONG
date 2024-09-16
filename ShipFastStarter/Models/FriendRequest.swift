struct FriendRequest: Identifiable, Codable, Hashable {
    let id: String
    let user: User
    let timestamp: Date

    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Implement Equatable (required for Hashable)
    static func == (lhs: FriendRequest, rhs: FriendRequest) -> Bool {
        return lhs.id == rhs.id
    }
}