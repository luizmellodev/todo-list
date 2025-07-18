//
//  TodoServiceProtocol.swift
//  todo-list
//
//  Created by Luiz Mello on 18/02/25.
//

import Foundation
import Combine

protocol TodoServiceProtocol {
    func fetchCategories(token: String) -> AnyPublisher<[Category], NetworkError>
    func createCategory(name: String, token: String) -> AnyPublisher<Category, NetworkError>
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError>
    func deleteTodos(ids: [String], token: String) -> AnyPublisher<[Todo], NetworkError>
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError>
}
class TodoService: TodoServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchCategories(token: String) -> AnyPublisher<[Category], NetworkError> {
        return networkManager.sendRequest("/categories_with_todos", method: "GET", parameters: nil, authentication: nil, token: token, body: nil)
            .eraseToAnyPublisher()
    }
    
    func createCategory(name: String, token: String) -> AnyPublisher<Category, NetworkError> {
        let newCategory = Category(id: UUID().uuidString, name: name, todos: [], createdAt: DateFormatter.formatDate(Date()))
        
        guard let jsonData = try? JSONEncoder().encode(newCategory) else {
            return Fail(error: NetworkError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return networkManager.sendRequest("/categories", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .eraseToAnyPublisher()
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        let newTodo = Todo(
            id: UUID().uuidString,
            username: "",
            content: content,
            completed: completed,
            createdAt: DateUtils.formatDateForAPI(Date()),
            categoryId: categoryId
        )
        
        guard let jsonData = try? JSONEncoder().encode(newTodo) else {
            return Fail(error: NetworkError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return networkManager.sendRequest("/todos", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .eraseToAnyPublisher()
    }
    
    func deleteTodos(ids: [String], token: String) -> AnyPublisher<[Todo], NetworkError> {
        let idsString = ids.joined(separator: ",")
        print("Sending IDs to delete: \(idsString)")
        
        let urlString = "/todos?ids=\(idsString)"
        
        return self.networkManager.sendRequest(
            urlString,
            method: "DELETE",
            parameters: nil,
            authentication: nil,
            token: token,
            body: nil
        )
        .eraseToAnyPublisher()
    }
    
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?, token: String) -> AnyPublisher<Todo, NetworkError> {
        let updateRequest = TodoRequest(content: content, completed: completed, categoryId: categoryId)
        
        guard let jsonData = try? JSONEncoder().encode(updateRequest) else {
            return Fail(error: NetworkError.decodingError)
                .eraseToAnyPublisher()
        }
        
        return networkManager.sendRequest("/todos/\(id)", method: "PUT", parameters: nil, authentication: nil, token: token, body: jsonData)
            .eraseToAnyPublisher()
    }
}

