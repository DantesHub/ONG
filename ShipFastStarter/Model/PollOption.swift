//
//  PollOption.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

struct PollOption: Codable, Equatable, FBObject, Comparable {
    static func < (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.userId > rhs.userId
    }
    
    var id: String
    let type: String?
    let option: String
    let userId: String
    let gradeLevel: String
    var priorityScore = 0

    init(id: String, type: String, option: String, userId: String, gradeLevel: String) {
        self.id = id
        self.type = type
        self.option = option
        self.userId = userId
        self.gradeLevel = gradeLevel
    }

    static func == (lhs: PollOption, rhs: PollOption) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, type, option, gradeLevel, userId
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
        option: "a classmate",
        userId: "user_id",
        gradeLevel: "9" // Example grade level
    )
}
