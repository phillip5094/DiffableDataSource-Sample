//
//  PeopleController.swift
//  DiffableDataSource-Sample
//
//  Created by NHN on 2022/02/19.
//

import Foundation

class PeopleController {
    struct Person: Hashable {
        let name: String
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Person, rhs: Person) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
        func contains(_ filter: String?) -> Bool {
            guard let filterText = filter else { return true }
            if filterText.isEmpty { return true }
            let lowecasedFilter = filterText.lowercased()
            return name.lowercased().contains(lowecasedFilter)
        }
    }
    
    func filteredPeople(with filter: String? = nil) -> [Person] {
        return people.filter { $0.contains(filter) }
    }
    
    private lazy var people: [Person] = {
        return generatePeople()
    }()
}

extension PeopleController {
    private func generatePeople() -> [Person] {
        let components = peopleRawData.components(separatedBy: CharacterSet.newlines)
        var people = [Person]()
        
        for line in components {
            people.append(Person(name: line))
        }
        return people
    }
}
