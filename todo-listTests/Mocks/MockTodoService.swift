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
    
    // Dados de teste constantes
    private let testUsername = "testuser"
    private let testDate = "2025-03-11"
    
    func fetchCategories(token: String) -> AnyPublisher<[todo_list.Category], NetworkError> {
        fetchCategoriesCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        
        let categories = [
            Category(
                id: "1",
                name: "Work",
                todos: [],
                createdAt: testDate
            ),
            Category(
                id: "2",
                name: "Personal",
                todos: [
                    Todo(
                        id: "todo1",
                        username: testUsername,
                        content: "Test Todo",
                        completed: false,
                        createdAt: testDate,
                        categoryId: "2"
                    )
                ],
                createdAt: testDate
            )
        ]
        return Just(categories)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func createCategory(name: String, token: String) -> AnyPublisher<todo_list.Category, NetworkError> {
        createCategoryCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        
        let category = Category(
            id: UUID().uuidString,
            name: name,
            todos: [],
            createdAt: testDate
        )
        return Just(category)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        
        let todo = Todo(
            id: UUID().uuidString,
            username: testUsername,
            content: content,
            completed: completed,
            createdAt: testDate,
            categoryId: categoryId
        )
        return Just(todo)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteTodos(ids: [String], token: String) -> AnyPublisher<[Todo], NetworkError> {
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        
        // Simula a deleção retornando os TODOs deletados
        let deletedTodos = ids.map { id in
            Todo(
                id: id,
                username: testUsername,
                content: "Deleted Todo",
                completed: false,
                createdAt: testDate,
                categoryId: nil
            )
        }
        return Just(deletedTodos)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        
        let todo = Todo(
            id: id,
            username: testUsername,
            content: content ?? "Updated Todo",
            completed: completed ?? false,
            createdAt: testDate,
            categoryId: categoryId
        )
        return Just(todo)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
