//
//  PollViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import FirebaseFirestore

class PollViewModel: ObservableObject {
    @Published var pollSet: [Poll] = [Poll.exPoll]
    @Published var selectedPoll = Poll.exPoll
    @Published var currentOptions: [PollOption] = []
    
    init() {
        loadPolls()
    }

    func loadPolls() {
        // Implement logic to load polls from Firebase or local storage
        // check to see based off userID if 8 new ones exist, if not, create them
        Task {
            do {
                let polls: [Poll] = try await FirebaseService.shared.fetchDocuments(collection: "polls", limit: 8)
                DispatchQueue.main.async {
//                    self.pollSet = polls
                    if let first = self.pollSet.first {
                        self.selectedPoll = first
                    }
                    self.getPollOptions()
                }
            } catch {
                print("Error loading polls: \(error.localizedDescription)")
            }
        }
    }

    func createPoll() {
        // Implement logic to create a new poll
    }

    func getPollResults() {
        // Implement logic to get poll results
    }
    
    func getPollOptions() {
        Task {
            do {
                let options: [PollOption] = try await FirebaseService.shared.fetchDocuments(
                    collection: "pollOptions",
                    whereField: "pollId",
                    isEqualTo: selectedPoll.id,
                    limit: 12
                )
                DispatchQueue.main.async {
                    self.currentOptions = options
                    self.objectWillChange.send()
                }
            } catch {
                print("Error getting poll options: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value of type '\(type)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type '\(type)': \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
            }
        }
    }

    func shufflePolls() {
        pollSet.shuffle()
    }
}
