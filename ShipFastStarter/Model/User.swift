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

    init(id: String, firstName: String, lastName: String, schoolId: String, color: String, aura: Int, godMode: Bool, birthday: String, grade: String, number: String, votedPolls: [String], lastPollFinished: Date?, friends: [String], invitedFriends: [String], ogBadge: Bool) {
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
        ogBadge: true
    )

    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, schoolId, color, aura, godMode, birthday, grade, number, votedPolls, lastPollFinished, friends, invitedFriends, ogBadge
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        schoolId = try container.decode(String.self, forKey: .schoolId)
        color = try container.decode(String.self, forKey: .color)
        aura = try container.decode(Int.self, forKey: .aura)
        godMode = try container.decode(Bool.self, forKey: .godMode)
        birthday = try container.decode(String.self, forKey: .birthday)
        grade = try container.decode(String.self, forKey: .grade)
        number = try container.decode(String.self, forKey: .number)
        votedPolls = try container.decode([String].self, forKey: .votedPolls)
        friends = try container.decode([String].self, forKey: .friends)
        invitedFriends = try container.decode([String].self, forKey: .invitedFriends)
        ogBadge = try container.decode(Bool.self, forKey: .ogBadge)

        // Custom decoding for lastPollFinished
        if let lastPollFinishedTimestamp = try? container.decode(Double.self, forKey: .lastPollFinished) {
            lastPollFinished = Date(timeIntervalSince1970: lastPollFinishedTimestamp)
        } else if let lastPollFinishedString = try? container.decode(String.self, forKey: .lastPollFinished),
                  let lastPollFinishedDate = ISO8601DateFormatter().date(from: lastPollFinishedString) {
            lastPollFinished = lastPollFinishedDate
        } else {
            lastPollFinished = Date() // Default to current date if unable to parse
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
