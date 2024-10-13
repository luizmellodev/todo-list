//
//  Todo.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation


struct Todo: Identifiable, Codable {
    let id: String
    var content: String
    var completed: Bool
    var categoryId: String?
    var createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, content, completed
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}

struct TodoRequest: Codable {
    var content: String?
    var completed: Bool?
    var categoryId: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case content, completed
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}

