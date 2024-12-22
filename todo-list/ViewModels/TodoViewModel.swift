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
    @Published var draggedTodo: Todo?
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func updateTodoById(id: String, content: String?, completed: Bool?, categoryId: String?, createdAt: String?) {
        guard let url = URL(string: "\(baseURL)/todos/\(id)") else {
            print("Invalid URL for updating todo")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updateTodoRequest = TodoRequest(
            content: content,
            completed: completed,
            categoryId: categoryId,
            createdAt: createdAt
        )
        
        do {
            let jsonData = try JSONEncoder().encode(updateTodoRequest)
            request.httpBody = jsonData
        } catch {
            print("Error encoding update request")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: Todo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error updating todo: \(error)")
                }
            }, receiveValue: { [weak self] updatedTodo in
                print("Todo updated successfully: \(updatedTodo)")
                // Atualizar a categoria localmente, se necessário
                if let index = self?.categories.firstIndex(where: { $0.todos.contains(where: { $0.id == id }) }),
                   let todoIndex = self?.categories[index].todos.firstIndex(where: { $0.id == id }) {
                    self?.categories[index].todos[todoIndex] = updatedTodo
                }
            })
            .store(in: &cancellables)
    }
    
    func deleteTodos(at offsets: IndexSet, in category: Category) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) else { return }
        
        for index in offsets {
            let todo = categories[categoryIndex].todos[index]
            guard let url = URL(string: "\(baseURL)/todos/\(todo.id)") else {
                print("Invalid URL for deleting todo")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    print("Error deleting todo: \(error)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.categories[categoryIndex].todos.remove(at: index)
                        if self.categories[categoryIndex].todos.isEmpty {
                            self.categories.remove(at: categoryIndex)
                        }
                    }
                }
            }.resume()
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
