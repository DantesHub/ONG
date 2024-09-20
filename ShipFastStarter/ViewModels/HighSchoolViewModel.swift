//
//  HighSchoolViewModel.swift
//  ONG
//
//  Created by Dante Kim on 9/3/24.
//

import Foundation
import Combine
import FirebaseFirestore

struct School: Codable, Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let state: String
}

class HighSchoolViewModel: ObservableObject {
    @Published var schools: [School] = []
    @Published var searchQuery = ""
    @Published var isHighSchoolLocked = true
    @Published var totalKids = 0
    @Published var selectedHighschool: Highschool = Highschool.exHighSchool
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchSchools(query: query)
            }
            .store(in: &cancellables)        
    }
    
    @MainActor
    func checkHighSchoolLock(for user: User, id: String) async {
        do {
            totalKids = 0
            selectedHighschool = try await FirebaseService.shared.getDocument(collection: "highschools", documentId: id)
            totalKids = selectedHighschool.students.count
            // Adjust this threshold as needed
            self.isHighSchoolLocked = totalKids <= 11
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } catch {
            print("Error checking high school lock: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateNumStudents(user: User, for highschoolId: String) {
        Task {        
            var students = selectedHighschool.students
            students.append(user.id)
            selectedHighschool.students = students
            try await FirebaseService.shared.updateField(collection: "highschools", documentId: highschoolId, field: "students", value: students)
            totalKids = students.count
        }
     
    }
    
    func searchSchools(query: String) {                
        guard !query.isEmpty else {
            schools = []
            return
        }    
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/us-public-schools/records?limit=20&where=name%20like%20%27%25\(encodedQuery)%25%27&select=name,city,state"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SchoolResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.schools = response.results.map { result in
                    School(name: result.name,
                           city: result.city,
                           state: result.state)
                }
            }.store(in: &cancellables)
    }
}

// Updated helper structs for decoding the API response
struct SchoolResponse: Codable {
    let totalCount: Int
    let results: [SchoolResult]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case results
    }
}

struct SchoolResult: Codable {
    let name: String
    let city: String
    let state: String
}
