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
    
    func fetchCategories() {
        NetworkManager.shared.fetch(from: "categories_with_todos")
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
        
        NetworkManager.shared.create(to: "todos", body: newTodo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error creating todo: \(error)")
                }
            }, receiveValue: {
                if let categoryIndex = self.categories.firstIndex(where: { $0.id == categoryId }) {
                    self.categories[categoryIndex].todos.append(newTodo)
                }
            })
            .store(in: &cancellables)
    }
}
