//
//  PollOption.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

struct PollOption: Codable, Equatable, FBObject {
    var id: String
    let type: String?
    let pollId: String
    let option: String
    var votes: [String: Int]?
    let gradeLevel: String
    var computedProgress: Double = 0 // Make this mutable

    init(id: String, type: String, pollId: String, option: String, votes: [String: Int], gradeLevel: String) {
        self.id = id
        self.type = type
        self.pollId = pollId
        self.option = option
        self.votes = votes
        self.gradeLevel = gradeLevel
    }

    static func == (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, pollId, option, votes, gradeLevel
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding PollOption to dictionary: \(error)")
            return nil
        }
    }

    static var exPollOption = PollOption(
        id: "example_option_id",
        type: "Interest Based Question",
        pollId: "example_poll_id",
        option: "Example Option",
        votes: [:],
        gradeLevel: "9" // Example grade level
    )
}
