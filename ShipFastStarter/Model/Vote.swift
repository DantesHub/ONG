//
//  Vote.swift
//  ONG
//
//  Created by Katherine Curtis on 10/3/24.
//

import SwiftData
import Foundation

struct Vote: Codable, Equatable, FBObject {
    var id: String
    var voterId: String
    var votedForId: String
    var schoolId: String
    var votedForOptionIndex: Int
    var amount: Int
    var question: String
    var pollId: String
    var createdAt: Date
    var viewedNotification: Bool
    var pollOptions: [String]

    static var exVote = Vote(
      id: "example_vote_id",
      voterId: "example_voter_id",
      votedForId: "example_voted_for_id",
      schoolId: "example_school_id",
      votedForOptionIndex: 0,
      amount: 100,
      pollId: "example_poll_id",
      createdAt: Date(),
      viewedNotification: false,
      pollOptions: ["UserA", "UserB", "UserC", "UserD"],
      question: "example_question"
    )

    static func == (lhs: Vote, rhs: Vote) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, voterId, votedForId, schoolId, votedForOptionIndex, amount, pollId, createdAt, viewedNotification, pollOptions, question
    }

    init(id: String, voterId: String, votedForId: String, schoolId: String, votedForOptionIndex: Int, amount: Int, pollId: String, createdAt: Date, viewedNotification: Bool, pollOptions: [String], question: String) {
        self.id = id
        self.voterId = voterId
        self.votedForId = votedForId
        self.schoolId = schoolId
        self.votedForOptionIndex = votedForOptionIndex
        self.amount = amount
        self.pollId = pollId
        self.createdAt = createdAt
        self.viewedNotification = viewedNotification
        self.pollOptions = pollOptions
        self.question = question
        
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        voterId = try container.decode(String.self, forKey: .voterId)
        votedForId = try container.decode(String.self, forKey: .votedForId)
        schoolId = try container.decode(String.self, forKey: .schoolId)
        votedForOptionIndex = try container.decode(Int.self, forKey: .votedForOptionIndex)
        amount = try container.decode(Int.self, forKey: .amount)
        pollId = try container.decode(String.self, forKey: .pollId)
        viewedNotification = try container.decode(Bool.self, forKey: .viewedNotification)
        pollOptions = try container.decode([String].self, forKey: .pollOptions)
        question = try container.decode(String.self, forKey: .question)
        
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
            print("Error encoding Vote to dictionary: \(error)")
            return nil
        }
    }
}
