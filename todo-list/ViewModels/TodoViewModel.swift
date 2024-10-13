//
//  TodoViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//
import Foundation

class CategoriesViewModel: ObservableObject {
    
    @Published var categories: [Category] = []
    
    private let baseURL = "http://localhost:8000"
    
    func fetchCategories() {
        guard let url = URL(string: "\(baseURL)/categories_with_todos") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching categories: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedCategories = try JSONDecoder().decode([Category].self, from: data)
                DispatchQueue.main.async {
                    self?.categories = decodedCategories
                }
            } catch {
                print("Error decoding categories: \(error)")
            }
        }
        
        task.resume()
    }
}
