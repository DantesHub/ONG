//
//  HighSchool.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import SwiftData
import Foundation

struct HighSchool: Codable, Equatable, FBObject {
    var id: String
    var name: String
    var location: String
    var totalAura: Int
    var auraThisWeek: Int
    var pollIds: [String]
    var students: [String]
    var lat: String
    var long: String
    var county: String

    init(id: String, name: String, location: String, totalAura: Int, auraThisWeek: Int, pollIds: [String], students: [String], lat: String, long: String, county: String) {
        self.id = id
        self.name = name
        self.location = location
        self.totalAura = totalAura
        self.auraThisWeek = auraThisWeek
        self.pollIds = pollIds
        self.students = students
        self.lat = lat
        self.long = long
        self.county = county
    }

    static var exHighSchool = HighSchool(
        id: "123e4567-e89b-12d3-a456-426614174000",
        name: "buildspace",
        location: "Example City, State",
        totalAura: 1000,
        auraThisWeek: 100,
        pollIds: [],
        students: [],
        lat: "40.7128",
        long: "-74.0060",
        county: "Example County"
    )

    static func == (lhs: HighSchool, rhs: HighSchool) -> Bool {
        return lhs.id == rhs.id
    }

    enum CodingKeys: String, CodingKey {
        case id, name, location, totalAura, auraThisWeek, pollIds, students, lat, long, county
    }

    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding HighSchool to dictionary: \(error)")
            return nil
        }
    }
}
