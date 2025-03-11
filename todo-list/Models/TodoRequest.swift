//
//  TodoRequest.swift
//  todo-list
//
//  Created by Luiz Mello on 13/10/24.
//

import Foundation

struct TodoRequest: Codable {
    var content: String?
    var username: String?
    var completed: Bool?
    var categoryId: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case content, completed, username
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}
