//
//  Todo.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation


struct Todo: Identifiable, Codable {
    let id: String
    var username: String
    var content: String
    var completed: Bool
    var createdAt: String
    var categoryId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, username, content, completed
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
    
    static let placeholder = Todo(id: UUID().uuidString, username: "username", content: "Placeholder Todo", completed: false, createdAt: "\(Date())", categoryId: "")
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

