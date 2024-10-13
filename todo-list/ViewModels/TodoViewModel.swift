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
    
    private let baseURL = "http://localhost:8000"
    
    func fetchCategories() {
        guard let url = URL(string: "\(baseURL)/categories_with_todos") else {
            print("Invalid URL for fetching categories")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Category].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<[Category]> in
                print("Error fetching categories: \(error)")
                return Just([])
            }
            .assign(to: &$categories)
    }
    
    func createTodo(content: String, completed: Bool, categoryId: String?) {
        guard let url = URL(string: "\(baseURL)/todos") else {
            print("Invalid URL for creating todo")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let newTodo = Todo(
            id: UUID().uuidString,
            content: content,
            completed: completed,
            categoryId: categoryId,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
        
        do {
            let jsonData = try JSONEncoder().encode(newTodo)
            request.httpBody = jsonData
        } catch {
            print("Error encoding todo: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: Todo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Todo> in
                print("Error creating todo: \(error)")
                return Just(Todo(id: "", content: "", completed: false, categoryId: "", createdAt: Date().description))
            }
            .sink(receiveValue: { [weak self] newTodo in
                if newTodo.id.isEmpty {
                    print("Failed to create todo: no id returned from the server")
                    return
                }
                if let categoryIndex = self?.categories.firstIndex(where: { $0.id == categoryId }) {
                    self?.categories[categoryIndex].todos.append(newTodo)
                }
            })
            .store(in: &cancellables)
    }

}
