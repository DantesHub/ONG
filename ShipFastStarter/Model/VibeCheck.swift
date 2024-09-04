//
//  VibeCheck.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

struct VibeCheck: Codable, Equatable, FBObject {
    var id: String
    var userOne: String
    var userTwo: String
    var score: String
    var music: String
    var entertainment: String

    init(id: String, userOne: String, userTwo: String, score: String, music: String, entertainment: String) {
        self.id = id
        self.userOne = userOne
        self.userTwo = userTwo
        self.score = score
        self.music = music
        self.entertainment = entertainment
    }

    static var exVibeCheck = VibeCheck(
        id: "example_vibe_check_id",
        userOne: "user_one_id",
        userTwo: "user_two_id",
        score: "85",
        music: "Pop, Rock",
        entertainment: "Movies, TV Shows"
    )

    static func == (lhs: VibeCheck, rhs: VibeCheck) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, userOne, userTwo, score, music, entertainment
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding VibeCheck to dictionary: \(error)")
            return nil
        }
    }

    func calculateVibeScore() {
        // Implementation for calculateVibeScore logic
        // Check if at least 10 IBQs are answered, with at least 7 being the same
        // Calculate percentage of same votes
        // Check for common interests in music, entertainment, etc.
        // Consider factors like social activities, goals, communication, lifestyle, and hot takes
    }
}
