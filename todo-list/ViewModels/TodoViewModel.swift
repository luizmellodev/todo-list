//
//  TodoViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation
import Combine

class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
    @Published var state: DefaultViewState = .loading
    
        
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchCategories(token: String) {
        networkManager.sendRequest("/categories_with_todos", method: "GET", parameters: nil, authentication: nil, token: token, body: nil)
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<[Category]> in
                print("Error fetching categories: \(error)")
                self.state = .noConnection
                return Just([])
            }
            .assign(to: &$categories)
        
        self.state = .requestSucceeded
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) {
        let newTodo = Todo(
            id: UUID().uuidString,
            username: "",
            content: content,
            completed: completed,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            categoryId: categoryId
        )
        
        guard let jsonData = try? JSONEncoder().encode(newTodo) else {
            print("Error encoding new todo")
            return
        }
        
        networkManager.sendRequest("/todos", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error creating todo: \(error)")
                }
            }, receiveValue: { (createdTodo: Todo) in
                self.appendTodoToCategory(createdTodo, categoryId: categoryId)
            })
            .store(in: &cancellables)
    }
    
    func deleteTodos(at offsets: IndexSet, in category: Category, token: String) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        for index in offsets {
            let todo = categories[categoryIndex].todos[index]

            networkManager.sendRequest("/todos/\(todo.id)", method: "DELETE", parameters: nil, authentication: nil, token: token, body: nil)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.removeTodoFromCategory(todo, at: categoryIndex)
                    case .failure(let error):
                        print("Error deleting todo: \(error)")
                    }
                }, receiveValue: { (todo: Todo) in
                    print("deleted!")
                    self.removeTodoFromCategory(todo, at: categoryIndex)
                })
                .store(in: &cancellables)
        }
    }
    
    func updateTodo(id: String, content: String?, username: String?, completed: Bool?, categoryId: String?, token: String) {
        let updateRequest = TodoRequest(content: content, completed: completed, categoryId: categoryId)
        
        guard let jsonData = try? JSONEncoder().encode(updateRequest) else {
            print("Error encoding update request")
            return
        }
        
        networkManager.sendRequest("/todos/\(id)", method: "PUT", parameters: nil, authentication: nil, token: token, body: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.fetchCategories(token: token)
                case .failure(let error):
                    print("Error updating todo: \(error)")
                }
            }, receiveValue: { (todo: Todo) in
                print("Updated Todo: \(todo)")
            })
            .store(in: &cancellables)
    }
}

extension CategoriesViewModel {
    private func appendTodoToCategory(_ todo: Todo, categoryId: String?) {
        guard let categoryId = categoryId else { return }
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[categoryIndex].todos.append(todo)
        }
    }
    
    private func removeTodoFromCategory(_ todo: Todo, at categoryIndex: Int) {
        if let todoIndex = categories[categoryIndex].todos.firstIndex(where: { $0.id == todo.id }) {
            categories[categoryIndex].todos.remove(at: todoIndex)
            
            if categories[categoryIndex].todos.isEmpty {
                categories.remove(at: categoryIndex)
            }
        }
    }
}
