//
//  MockTodoService.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import XCTest
import Combine
@testable import todo_list

class MockTodoService: TodoServiceProtocol {
    var shouldFail = false
    var fetchCategoriesCalled = false
    var createCategoryCalled = false
    
    func fetchCategories(token: String) -> AnyPublisher<[todo_list.Category], NetworkError> {
        fetchCategoriesCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        let categories = [Category(id: "1", name: "Work", todos: [], createdAt: "2025-03-11")]
        return Just(categories).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
    
    func createCategory(name: String, token: String) -> AnyPublisher<todo_list.Category, NetworkError> {
        createCategoryCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        let category = Category(id: "2", name: name, todos: [], createdAt: "2025-03-11")
        return Just(category).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        return Fail(error: .badServerResponse).eraseToAnyPublisher()
    }
    
    func deleteTodos(ids: [String], token: String) -> AnyPublisher<Void, NetworkError> {
        return Fail(error: .badServerResponse).eraseToAnyPublisher()
    }
    
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        return Fail(error: .badServerResponse).eraseToAnyPublisher()
    }
}
