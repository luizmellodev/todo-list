//
//  TodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//

import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.categories) { category in
                Section(header: Text(category.name)) {
                    ForEach(category.todos) { todo in
                        HStack {
                            Text(todo.content)
                                .strikethrough(todo.completed)
                                .foregroundStyle(todo.completed ? .gray : .primary)

                            Spacer()
                            
                            Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                                .padding(3)
                                .contentShape(.rect)
                                .foregroundStyle(todo.completed ? .gray : .accentColor)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            viewModel.fetchCategoriesWithTodos()
        }
    }
}

#Preview {
    TodoView()
}
