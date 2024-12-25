//
//  WidgetIntent.swift
//  TodoWidgetExtension
//
//  Created by Luiz Mello on 24/12/24.
//

import Foundation
import AppIntents
import WidgetKit

//@available(iOS 17.0, *)
struct MarkAsDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Mark Todo as Done"
    
    let data = DataService()
    
    @Parameter(title: "Todo ID")
    var todoId: String
    
    init() {}
    
    init(todoId: String) {
        self.todoId = todoId
    }
    
    func perform() async throws -> some IntentResult {
        var todos = data.fetchTodos()
        
        if let index = todos.firstIndex(where: { $0.id == todoId }) {
            let isCompleted = todos[index].completed
            todos[index].completed = isCompleted ? false : true
            data.saveTodos(todos)
        }
        
        return .result()
    }
}

