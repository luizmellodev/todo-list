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
        ScrollView {
            VStack(spacing: 20) {
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
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $uiState.newTodoClicked) {
            AddTodoView(
                token: token,
                textFieldText: $uiState.textFieldText,
                selectedCategory: $viewModel.selectedCategory,
                viewModel: viewModel
            )
            .padding(.horizontal)
            .presentationDetents([.height(120)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func hasVisibleTodos(in category: Category) -> Bool {
        category.todos.compactMap { $0 }
            .filter { !uiState.hideCompleted || !$0.completed }
            .count > 0
    }
}
