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
}
