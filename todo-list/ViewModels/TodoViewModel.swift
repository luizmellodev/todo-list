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
    private let todoService: TodoServiceProtocol
    
    init(todoService: TodoServiceProtocol = TodoService()) {
        self.todoService = todoService
    }
    
    // MARK: - Categories
    func fetchCategories(token: String) {        
        todoService.fetchCategories(token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.state = .requestSucceeded
                case .failure:
                    self.state = .noConnection
                }
            }, receiveValue: { categories in
                self.categories = categories
                self.updateSelectedCategory(categories: categories)
                self.updateWidget()
            })
            .store(in: &cancellables)
    }
    
    private func updateSelectedCategory(categories: [Category]) {
        if let selectedCategoryId = self.selectedCategory?.id {
            self.selectedCategory = categories.first(where: { $0.id == selectedCategoryId })
        }
    }
    
    func createCategory(name: String, token: String, completion: @escaping (String?) -> Void) {
        todoService.createCategory(name: name, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.state = .requestSucceeded
                case .failure:
                    self.state = .noConnection
                }
            }, receiveValue: { createdCategory in
                self.categories.append(createdCategory)
                completion(createdCategory.id)
            })
            .store(in: &cancellables)
    }
    
    // MARK: - Todo
    func createTodo(content: String, completed: Bool, categoryId: String?, token: String) {
        todoService.createTodo(content: content, completed: completed, categoryId: categoryId, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.state = .requestSucceeded
                case .failure:
                    self.state = .noConnection
                }
            }, receiveValue: { createdTodo in
                self.appendTodoToCategory(createdTodo, categoryId: categoryId)
            })
            .store(in: &cancellables)
    }
    
    func deleteTodos(ids: [String], token: String) {
        todoService.deleteTodos(ids: ids, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Todos deleted successfully")

                    for categoryIndex in self.categories.indices {
                        self.categories[categoryIndex].todos.removeAll { todo in
                            guard let todo = todo else { return false }
                            return ids.contains(todo.id)
                        }
                    }

                case .failure(let error):
                    print("Failed to delete todos: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    
    
    func updateTodo(id: String, content: String?, completed: Bool?, categoryId: String?, token: String) {
        todoService.updateTodo(id: id, content: content, completed: completed, categoryId: categoryId, token: token)
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
