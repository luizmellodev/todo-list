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
    private var cancellables: Set<AnyCancellable> = []

    func fetchCategoriesWithTodos() {
        guard let url = URL(string: "http://localhost:8000/categories_with_todos") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Category].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$categories)
    }
}
