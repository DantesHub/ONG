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
    var schoolId: String
    var color: String
    var aura: Int
    var godMode: Bool
    var birthday: String
    var grade: String
    var number: String
    var votedPolls: [String]
    var lastPollFinished: Date?
    var friends: [String]
    var invitedFriends: [String]
    var ogBadge: Bool
    var gender: String // New property
    var fcmToken: String

    init(id: String, firstName: String, lastName: String, schoolId: String, color: String, aura: Int, godMode: Bool, birthday: String, grade: String, number: String, votedPolls: [String], lastPollFinished: Date?, friends: [String], invitedFriends: [String], ogBadge: Bool, gender: String, fcmToken: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
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
    }

    static var exUser = User(
        id: UUID().uuidString,
        firstName: "Naveed",
        lastName: "Johnmo",
        schoolId: "123e4567-e89b-12d3-a456-426614174000",
        color: "#FF0000",
        aura: 100,
        godMode: false,
        birthday: "2000-01-01",
        grade: "11",
        number: "1234567890",
        votedPolls: [],
        lastPollFinished: nil,
        friends: [],
        invitedFriends: [],
        ogBadge: true,
        gender: "Male", // Example gender
        fcmToken: ""
    )

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, schoolId, color, aura, godMode, birthday, grade, number, votedPolls, lastPollFinished, friends, invitedFriends, ogBadge, gender, fcmToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        schoolId = try container.decode(String.self, forKey: .schoolId)
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#000000" // Default black color
        aura = try container.decodeIfPresent(Int.self, forKey: .aura) ?? 0
        godMode = try container.decodeIfPresent(Bool.self, forKey: .godMode) ?? false
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday) ?? "2000-01-01" // Default birthday
        grade = try container.decodeIfPresent(String.self, forKey: .grade) ?? "9" // Default to 9th grade
        number = try container.decodeIfPresent(String.self, forKey: .number) ?? ""
        votedPolls = try container.decodeIfPresent([String].self, forKey: .votedPolls) ?? []
        friends = try container.decodeIfPresent([String].self, forKey: .friends) ?? []
        invitedFriends = try container.decodeIfPresent([String].self, forKey: .invitedFriends) ?? []
        ogBadge = try container.decodeIfPresent(Bool.self, forKey: .ogBadge) ?? false
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? "Unspecified" // Default gender
        fcmToken = try container.decodeIfPresent(String.self, forKey: .fcmToken) ?? ""
        // Custom decoding for lastPollFinished
        if let lastPollFinishedTimestamp = try? container.decode(Double.self, forKey: .lastPollFinished) {
            lastPollFinished = Date(timeIntervalSince1970: lastPollFinishedTimestamp)
        } else if let lastPollFinishedString = try? container.decode(String.self, forKey: .lastPollFinished),
                  let lastPollFinishedDate = ISO8601DateFormatter().date(from: lastPollFinishedString) {
            lastPollFinished = lastPollFinishedDate
        } else {
            lastPollFinished = nil
        }
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
