//
//  Category.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: String
    var name: String
    var todos: [Todo]
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, todos
        case createdAt = "created_at"
    }
}

