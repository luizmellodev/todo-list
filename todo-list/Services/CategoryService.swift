//
//  CategoryServiceProtocol.swift
//  todo-list
//
//  Created by Luiz Mello on 18/02/25.
//

import Foundation
import Combine

protocol CategoryServiceProtocol {
    func fetchCategories(token: String, completion: @escaping (Result<[Category], NetworkError>) -> Void)
    func createCategory(name: String, token: String, completion: @escaping (Result<Category, NetworkError>) -> Void)
}

class CategoryService: CategoryServiceProtocol {
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables = Set<AnyCancellable>()

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func fetchCategories(token: String, completion: @escaping (Result<[Category], NetworkError>) -> Void) {
        networkManager.sendRequest("/categories_with_todos", method: "GET", parameters: nil, authentication: nil, token: token, body: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionState in
                if case .failure(let error) = completionState {
                    completion(.failure(error))
                }
            }, receiveValue: { categories in
                completion(.success(categories))
            })
            .store(in: &cancellables)
    }
    
    func createCategory(name: String, token: String, completion: @escaping (Result<Category, NetworkError>) -> Void) {
        let newCategory = Category(
            id: UUID().uuidString,
            name: name,
            todos: [],
            createdAt: DateFormatter.formatDate(Date())
        )
        
        guard let jsonData = try? JSONEncoder().encode(newCategory) else {
            completion(.failure(.encodingError))
            return
        }
        
        networkManager.sendRequest("/categories", method: "POST", parameters: nil, authentication: nil, token: token, body: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionState in
                if case .failure(let error) = completionState {
                    completion(.failure(error))
                }
            }, receiveValue: { createdCategory in
                completion(.success(createdCategory))
            })
            .store(in: &cancellables)
    }
}
