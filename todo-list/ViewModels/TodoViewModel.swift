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
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching categories: \(error)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let categories = try JSONDecoder().decode([Category].self, from: data)
                    DispatchQueue.main.async {
                        self.categories = categories
                    }
                } catch {
                    print("Error decoding categories: \(error)")
                }
            }
            
            task.resume()
        }
}
