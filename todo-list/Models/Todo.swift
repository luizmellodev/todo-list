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
    
    init(
        id: String,
        username: String,
        content: String,
        completed: Bool,
        createdAt: String,
        categoryId: String? = nil
    ) {
        self.id = id
        self.username = username
        self.content = content
        self.completed = completed
        self.createdAt = createdAt
        self.categoryId = categoryId
    }
    
    static let placeholder = Todo(
        id: UUID().uuidString,
        username: "username",
        content: "Placeholder Todo",
        completed: false,
        createdAt: DateUtils.formatDateForAPI(Date()),
        categoryId: ""
    )
}
