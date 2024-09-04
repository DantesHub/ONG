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

    static var exPoll = Poll(
        id: "example_poll_id",
        title: "Example Poll",
        createdAt: Date(),
        pollOptions: ["example_option_id", "example_option_id", "example_option_id", "example_option_id"],
        isActive: true,
        schoolId: "example_school_id",
        grade: "All",
        type: "Interest Based Question",
        category: "General"
    )

    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, title, createdAt, pollOptions, isActive, schoolId, grade, type, category
    }

    init(id: String, title: String, createdAt: Date, pollOptions: [String], isActive: Bool, schoolId: String, grade: String, type: String, category: String) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.pollOptions = pollOptions
        self.isActive = isActive
        self.schoolId = schoolId
        self.grade = grade
        self.type = type
        self.category = category
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

    func createPoll() {
        // Implementation for createPoll logic
        // Add logic for making sure if we repeat the question not to use the same people
        // Add logic for number of questions person has answered
        // Sort and fetch from list of questions
        // Want to see which questions users are churning from
    }
}
