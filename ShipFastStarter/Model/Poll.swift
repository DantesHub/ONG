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
    var status: String
    var schoolId: String
    var grade: String
    var type: String
    let category: String
    var voteSummary: [String: Int] = [:]

    static var exPoll = Poll(
        id: "example_poll_id",
        title: "you'll see this when someone chooses you in a poll!",
        createdAt: Date(),
        status: "active",
        schoolId: "example_school_id",
        grade: "All",
        type: "Interest Based Question",
        category: "General",
        voteSummary: [:]
    )

    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey { 
        case id, title, createdAt, status, schoolId, grade, type, category, voteSummary 
    }

    init(id: String, title: String, createdAt: Date, status: String, schoolId: String, grade: String, type: String, category: String, voteSummary: [String: Int]) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.status = status
        self.schoolId = schoolId
        self.grade = grade
        self.type = type
        self.category = category
        self.voteSummary = voteSummary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        schoolId = try container.decode(String.self, forKey: .schoolId)
        grade = try container.decode(String.self, forKey: .grade)
        type = try container.decode(String.self, forKey: .type)
        category = try container.decode(String.self, forKey: .category)
        status = try container.decode(String.self, forKey: .status)
        voteSummary = try container.decode([String: Int].self, forKey: .voteSummary)
        // Custom decoding for createdAt
        if let createdAtTimestamp = try? container.decode(Double.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        } else if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
                  let createdAtDate = ISO8601DateFormatter().date(from: createdAtString) {
            createdAt = createdAtDate
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match format expected by ISO8601DateFormatter.")
        }
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
