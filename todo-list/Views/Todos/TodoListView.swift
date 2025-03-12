//
//  TodoListView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct TodoListView: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var uiState: TodoUIState
    let token: String
    
    var body: some View {
        List {
            let categoriesToShow = viewModel.selectedCategory.map { [$0] } ?? viewModel.categories
            
            ForEach(categoriesToShow.filter { hasVisibleTodos(in: $0) }) { category in
                if let categoryIndex = viewModel.categories.firstIndex(where: { $0.id == category.id }) {
                    TodoSection(
                        token: token,
                        textFieldUpdates: $uiState.textFieldUpdates,
                        editMode: $uiState.editMode,
                        category: $viewModel.categories[categoryIndex],
                        selectedTodoIDs: $uiState.selectedTodoIDs
                    )
                    .id(category.id)
                    .environmentObject(viewModel)
                }
            }
        }
        .sheet(isPresented: $uiState.newTodoClicked) {
            AddTodoView(
                token: token,
                textFieldText: $uiState.textFieldText,
                selectedCategory: $viewModel.selectedCategory,
                viewModel: viewModel
            )
            .padding(.horizontal)
            .presentationDetents([.height(100)])
        }
    }
    
    private func hasVisibleTodos(in category: Category) -> Bool {
        category.todos.compactMap { $0 }
            .filter { !uiState.hideCompleted || !$0.completed }
            .count > 0
    }
}
