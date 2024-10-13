//
//  Category.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation

struct Category: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var todos: [Todo]
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, todos
        case createdAt = "created_at"
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
