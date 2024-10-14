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
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
        
    func fetchCategories() {
        networkManager.fetch(from: "categories_with_todos")
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<[Category]> in
                print("Error fetching categories: \(error)")
                return Just([])
            }
            .assign(to: &$categories)
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?) {
        let newTodo = Todo(
            id: UUID().uuidString,
            content: content,
            completed: completed,
            categoryId: categoryId,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        networkManager.create(to: "todos", body: newTodo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error creating todo: \(error)")
                }
            }, receiveValue: {
                self.appendTodoToCategory(newTodo, categoryId: categoryId)
            })
            .store(in: &cancellables)
    }
    
    func deleteTodos(at offsets: IndexSet, in category: Category) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        for index in offsets {
            let todo = categories[categoryIndex].todos[index]
            networkManager.delete(from: "todos/\(todo.id)")
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.removeTodoFromCategory(todo, at: categoryIndex)
                    case .failure(let error):
                        print("Error deleting todo: \(error)")
                    }
                }, receiveValue: {})
                .store(in: &cancellables)
        }
    }
    
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?) {
        let updateRequest = TodoRequest(content: content, completed: completed, categoryId: categoryId)

        networkManager.update(to: "todos/\(id)", with: updateRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.fetchCategories()
                case .failure(let error):
                    print("Error updating todo: \(error)")
                }
            }, receiveValue: {})
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
        }
    }
}
