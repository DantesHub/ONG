//
//  Bug.swift
//  ONG
//
//  Created by Dante Kim on 9/22/24.
//

import Foundation
import FirebaseFirestore

struct Bug: Identifiable, Codable, FBObject {
    let id: String
    let title: String
    let description: String
    let date: Date    
    let userId: String
    let highschoolId: String
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         date: Date = Date(),
         userId: String,
         highschoolId: String) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.userId = userId
        self.highschoolId = highschoolId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let id = data["id"] as? String,
              let title = data["title"] as? String,
              let description = data["description"] as? String,
              let timestamp = data["date"] as? Timestamp,
              let userId = data["userId"] as? String,
              let highschoolId = data["highschoolId"] as? String else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.date = timestamp.dateValue()
        self.userId = userId
        self.highschoolId = highschoolId
    }
    
    func encode() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "description": description,
            "date": Timestamp(date: date),
            "userId": userId,
            "highschoolId": highschoolId
        ]
    }
    
    func encodeToDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        } catch {
            print("Error encoding Bug to dictionary: \(error)")
            return nil
        }
    }
}
