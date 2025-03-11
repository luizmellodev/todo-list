//
//  TodoViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import Foundation
import Combine
import WidgetKit

class TodoViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var state: DefaultViewState = .loading
    @Published var selectedCategory: Category?

    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManagerProtocol
            
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Fetching Categories
    func fetchCategories(token: String) {
        networkManager.sendRequest("/categories_with_todos", method: "GET", parameters: nil, authentication: nil, token: token, body: nil)
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<[Category]> in
                print("Error fetching categories: \(error)")
                self.state = .noConnection
                return Just([])
            }
            .handleEvents(receiveOutput: { categories in
                self.updateWidget()
                self.state = .requestSucceeded
                self.objectWillChange.send()

                if let selectedCategoryId = self.selectedCategory?.id {
                    self.selectedCategory = categories.first(where: { $0.id == selectedCategoryId })
                }
            })
            .assign(to: &$categories)
    }
    
    // MARK: - Category Operations
    func createCategory(name: String, token: String) {
        let newCategory = Category(
            id: UUID().uuidString,
            name: name,
            todos: [],
            createdAt: DateFormatter.formatDate(Date())
        )
        
        guard let jsonData = try? JSONEncoder().encode(newCategory) else {
            print("Error encoding new category")
            return
        }
        
        networkManager.sendRequest("/categories", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handleCompletion(completion, token: token)
            }, receiveValue: { createdCategory in
                self.categories.append(createdCategory)
                self.updateWidget()
            })
            .store(in: &cancellables)
    }

    // MARK: - Todo Operations
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) {
        let newTodo = Todo(
            id: UUID().uuidString,
            username: "",
            content: content,
            completed: completed,
            createdAt: DateFormatter.formatDate(Date()),
            categoryId: categoryId
        )
        
        guard let jsonData = try? JSONEncoder().encode(newTodo) else {
            print("Error encoding new todo")
            return
        }
        
        networkManager.sendRequest("/todos", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handleCompletion(completion, token: token)
            }, receiveValue: { createdTodo in
                self.appendTodoToCategory(createdTodo, categoryId: categoryId)
                self.updateWidget()
            })
            .store(in: &cancellables)
    }
    
    func deleteTodos(at offsets: IndexSet, in category: Category, token: String) {
        guard let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) else { return }

        let todosToDelete = offsets.compactMap { index in
            categories[categoryIndex].todos[index]
        }

        categories[categoryIndex].todos.remove(atOffsets: offsets)

        for todo in todosToDelete {
            networkManager.sendRequest("/todos/\(todo.id)", method: "DELETE", parameters: nil, authentication: nil, token: token, body: nil)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    self.handleCompletion(completion, token: token)
                }, receiveValue: { (_: Todo) in
                    self.checkAndRemoveEmptyCategory(at: categoryIndex)
                    self.updateWidget()
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
                self.handleCompletion(completion, token: token)
            }, receiveValue: { (updatedTodo: Todo) in
                print("Updated Todo: \(updatedTodo)")
            })
            .store(in: &cancellables)
    }
}

// MARK: - Private Helper Functions
extension TodoViewModel {
    
    private func handleCompletion(_ completion: Subscribers.Completion<NetworkError>, token: String) {
        switch completion {
        case .finished:
            self.fetchCategories(token: token)
        case .failure(let error):
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print("Request failed with error: \(error)")
        // TODO: Change to other status
        state = .requestSucceeded
    }
    
    private func appendTodoToCategory(_ todo: Todo, categoryId: String?) {
        guard let categoryId = categoryId else { return }
        if let categoryIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[categoryIndex].todos.append(todo)
            selectedCategory = categories[categoryIndex]
        }
    }
    
    private func checkAndRemoveEmptyCategory(at categoryIndex: Int) {
        if categories[categoryIndex].todos.isEmpty {
            categories.remove(at: categoryIndex)
        }
    }
    
    private func updateWidget() {
        let incompleteTodos = categories.flatMap { $0.todos.compactMap { $0 } }
            .filter { !$0.completed }
        
        let lastSevenTodos = Array(incompleteTodos.prefix(7))
        
        saveTodosToAppStorage(lastSevenTodos)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveTodosToAppStorage(_ todos: [Todo]) {
        if let encoded = try? JSONEncoder().encode(todos) {
            UserDefaults(suiteName: "group.luizmello.todolist")?.set(encoded, forKey: "todos")
        }
    }
}

// MARK: - DateFormatter Extension
public extension DateFormatter {
    static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
