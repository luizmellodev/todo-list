//
//  Category.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: String
    let name: String
    var todos: [Todo]
}

