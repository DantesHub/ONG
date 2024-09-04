//
//  Poll.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

struct Poll: Codable, Equatable, FBObject {
    var id: String
    let title: String
    let createdAt: Date
    var pollOptions: [String]
    var isActive: Bool
    var schoolId: String
    var grade: String
    var type: String
    let category: String
    var usersWhoVoted: [String] // New field

    static var exPoll = Poll(
        id: "example_poll_id",
        title: "Example Poll",
        createdAt: Date(),
        pollOptions: ["example_option_id", "example_option_id", "example_option_id", "example_option_id"],
        isActive: true,
        schoolId: "example_school_id",
        grade: "All",
        type: "Interest Based Question",
        category: "General",
        usersWhoVoted: []
    )

    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, title, createdAt, pollOptions, isActive, schoolId, grade, type, category, usersWhoVoted
    }

    init(id: String, title: String, createdAt: Date, pollOptions: [String], isActive: Bool, schoolId: String, grade: String, type: String, category: String, usersWhoVoted: [String] = []) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.pollOptions = pollOptions
        self.isActive = isActive
        self.schoolId = schoolId
        self.grade = grade
        self.type = type
        self.category = category
        self.usersWhoVoted = usersWhoVoted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        pollOptions = try container.decode([String].self, forKey: .pollOptions)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        schoolId = try container.decode(String.self, forKey: .schoolId)
        grade = try container.decode(String.self, forKey: .grade)
        type = try container.decode(String.self, forKey: .type)
        category = try container.decode(String.self, forKey: .category)
        usersWhoVoted = try container.decode([String].self, forKey: .usersWhoVoted)
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding Poll to dictionary: \(error)")
            return nil
        }
    }

}
