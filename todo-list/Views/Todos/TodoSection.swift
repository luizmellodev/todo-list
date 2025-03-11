//
//  TodoSection.swift
//  todo-list
//
//  Created by Luiz Mello on 08/02/25.
//

import SwiftUI

struct TodoSection: View {
    
    let token: String
    
    @EnvironmentObject var viewModel: TodoViewModel
    
    @Binding var textFieldUpdates: [String: String]
    @Binding var editMode: EditMode
    @Binding var category: Category
    
    var body: some View {
        Section(header: Text(category.name)) {
            ForEach(category.todos.indices, id: \.self) { index in
                TodoRowView(
                    todo: $category.todos[index],
                    editMode: $editMode,
                    textUpdate: $textFieldUpdates,
                    token: token
                )
                .id(category.todos[index]?.id)
                .environmentObject(viewModel)
            }
            .onDelete { indexSet in
                viewModel.deleteTodos(at: indexSet, in: category, token: token)
            }
        }
    }
    
    private func filteredTodos(in category: Category) -> [Todo] {
        return category.todos.compactMap { $0 }
    }
}
