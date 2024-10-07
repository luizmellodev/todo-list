//
//  Todo.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation


struct Todo: Identifiable, Codable {
    let id: String
    let content: String
    let completed: Bool
    let categoryId: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case completed
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}
