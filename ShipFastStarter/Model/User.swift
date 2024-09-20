//
//  User.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

protocol FBObject {
    var id: String { get }
    func encodeToDictionary() -> [String: Any]?
}

struct User: Codable, Equatable, FBObject {
    var id: String
    var firstName: String
    var lastName: String
    var username: String
    var schoolId: String
    var color: String
    var aura: Int
    var godMode: Bool
    var birthday: String
    var grade: String
    var number: String
    var votedPolls: [String]
    var lastPollFinished: Date?
    var friends: [String: String]  // Changed to dictionary
    var invitedFriends: [String]
    var ogBadge: Bool
    var gender: String
    var fcmToken: String
    var proPic: String
    var referral: Int
    var crushId: String
    var friendsStatus: String = "Add +"
    var friendRequests: [String: String]
    var dateJoined: String
    
    // New properties
    var relationshipStatus: String
    var mbti: String
    var movie: String
    var music: String
    var bio: String  // New bio property

    init(id: String, firstName: String, lastName: String, username: String, schoolId: String, color: String, aura: Int, godMode: Bool, birthday: String, grade: String, number: String, votedPolls: [String], lastPollFinished: Date?, friends: [String: String], invitedFriends: [String], ogBadge: Bool, gender: String, fcmToken: String, proPic: String, referral: Int = 0, crushId: String = "", friendRequests: [String: String], dateJoined: String, relationshipStatus: String, mbti: String, movie: String, music: String, bio: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.schoolId = schoolId
        self.color = color
        self.aura = aura
        self.godMode = godMode
        self.birthday = birthday
        self.grade = grade
        self.number = number
        self.votedPolls = votedPolls
        self.lastPollFinished = lastPollFinished
        self.friends = friends
        self.invitedFriends = invitedFriends
        self.ogBadge = ogBadge
        self.gender = gender
        self.fcmToken = fcmToken
        self.proPic = proPic
        self.referral = referral
        self.crushId = crushId
        self.friendRequests = friendRequests
        self.dateJoined = dateJoined
        self.relationshipStatus = relationshipStatus
        self.mbti = mbti
        self.movie = movie
        self.music = music
        self.bio = bio
    }

    static var exUser = User(
        id: UUID().uuidString,
        firstName: "Naveed",
        lastName: "Johnmo",
        username: "naveedjohnmo",
        schoolId: "123e4567-e89b-12d3-a456-426614174000",
        color: "#FF0000",
        aura: 100,
        godMode: false,
        birthday: "2000-01-01",
        grade: "11",
        number: "+12013333333",
        votedPolls: [],
        lastPollFinished: nil,
        friends: [:],
        invitedFriends: [],
        ogBadge: true,
        gender: "Male",
        fcmToken: "",
        proPic: "https://firebasestorage.googleapis.com/v0/b/ongod-fce40.appspot.com/o/profileImages%2FOkl?alt=media&token=000ea88e-bce7-4167-b332-5df492744d68",
        referral: 0,
        crushId: "",
        friendRequests: [:],
        dateJoined: "2024-09-15",
        relationshipStatus: "signgle af",
        mbti: "INTJ",
        movie: "whiplash",
        music: "the end",
        bio: "a school to work on ur ideas"
    )

    
    


    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, username, schoolId, color, aura, godMode, birthday, grade, number, votedPolls, lastPollFinished, friends, invitedFriends, ogBadge, gender, fcmToken, proPic, referral, crushId, friendRequests, dateJoined
        // New coding keys
        case relationshipStatus, mbti, movie, music, bio
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        username = try container.decodeIfPresent(String.self, forKey: .username) ?? ""
        schoolId = try container.decode(String.self, forKey: .schoolId)
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000"
        aura = try container.decodeIfPresent(Int.self, forKey: .aura) ?? 0
        godMode = try container.decodeIfPresent(Bool.self, forKey: .godMode) ?? false
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday) ?? "2000-01-01"
        grade = try container.decodeIfPresent(String.self, forKey: .grade) ?? "9"
        number = try container.decodeIfPresent(String.self, forKey: .number) ?? ""
        votedPolls = try container.decodeIfPresent([String].self, forKey: .votedPolls) ?? []
        friends = try container.decodeIfPresent([String: String].self, forKey: .friends) ?? [:]  // Changed to dictionary
        invitedFriends = try container.decodeIfPresent([String].self, forKey: .invitedFriends) ?? []
        ogBadge = try container.decodeIfPresent(Bool.self, forKey: .ogBadge) ?? false
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "Unspecified"
        fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken) ?? ""
        proPic = try container.decodeIfPresent(String.self, forKey: .proPic) ?? ""
        referral = try container.decodeIfPresent(Int.self, forKey: .referral) ?? 0
        crushId = try container.decodeIfPresent(String.self, forKey: .crushId) ?? ""
        friendRequests = try container.decodeIfPresent([String: String].self, forKey: .friendRequests) ?? ["shiva":"shiva2"]  // Changed to dictionary
        dateJoined = try container.decodeIfPresent(String.self, forKey: .dateJoined) ?? Date().toString(format: "yyyy-MM-dd")
        // Custom decoding for lastPollFinished
        if let lastPollFinishedTimestamp = try? container.decode(Double.self, forKey: .lastPollFinished) {
            lastPollFinished = Date(timeIntervalSince1970: lastPollFinishedTimestamp)
        } else if let lastPollFinishedString = try? container.decode(String.self, forKey: .lastPollFinished),
                  let lastPollFinishedDate = ISO8601DateFormatter().date(from: lastPollFinishedString) {
            lastPollFinished = lastPollFinishedDate
        } else {
            lastPollFinished = nil
        }
        
        // New property decoding (now required)
        relationshipStatus = try container.decodeIfPresent(String.self, forKey: .relationshipStatus) ?? "single af"
        mbti = try container.decodeIfPresent(String.self, forKey: .mbti) ?? "INTJ"
        movie = try container.decodeIfPresent(String.self, forKey: .movie) ?? "whiplash"
        music = try container.decodeIfPresent(String.self, forKey: .music) ?? "the end"
        bio = try container.decodeIfPresent(String.self, forKey: .bio) ?? "a school to work on ur ideas"
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding User to dictionary: \(error)")
            return nil
        }
    }
}
