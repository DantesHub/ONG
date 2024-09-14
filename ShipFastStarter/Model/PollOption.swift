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
    let option: String
    let userId: String
    var votes: [String: [String: String]]?
    // id: [date: timeStamp, numVotes: "100", viewedNotification: "true"]
    let gradeLevel: String
    var computedProgress: Double = 0 // Make this mutable

    init(id: String, type: String, option: String, userId: String, votes: [String: [String: String]], gradeLevel: String) {
        self.id = id
        self.type = type
        self.option = option
        self.userId = userId
        self.votes = votes
        self.gradeLevel = gradeLevel
    }

    static func == (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, option, votes, gradeLevel, userId
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
        option: "Example Option",
        userId: "user_id",
        votes: [:],
        gradeLevel: "9" // Example grade level
    )
}
