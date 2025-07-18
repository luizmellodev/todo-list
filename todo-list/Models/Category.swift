//
//  CategoryDTO.swift
//  todo-list
//
//  Created by Luiz Mello on 05/02/25.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var createdAt: String
    var todos: [Todo] = []
    
    enum CodingKeys: String, CodingKey {
        case id, name, todos
        case createdAt = "created_at"
    }
    
    init(id: String, name: String, todos: [Todo], createdAt: String) {
        self.id = id
        self.name = name
        self.todos = todos
        self.createdAt = createdAt
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
