//
//  DataService.swift
//  TodoWidgetExtension
//
//  Created by Luiz Mello on 24/12/24.
//

import Foundation
import SwiftUI

struct DataService {
    @AppStorage("todos", store: UserDefaults(suiteName: "group.luizmello.todolist")) private var todosData: Data?
    
    func saveTodos(_ todos: [Todo]) {
        if let encoded = try? JSONEncoder().encode(todos) {
            todosData = encoded
        }
    }
    
    func fetchTodos() -> [Todo] {
        if let data = todosData, let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            return decoded
        }
        return []
    }
}
