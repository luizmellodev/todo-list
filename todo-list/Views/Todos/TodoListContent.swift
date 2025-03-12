//
//  TodoListContent.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct TodoListContent: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var uiState: TodoUIState
    let token: String
    
    var body: some View {
        Group {
            if let selectedCategory = viewModel.selectedCategory,
               selectedCategory.todos.isEmpty {
                EmptyStateView()
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
            } else {
                TodoListView(
                    viewModel: viewModel,
                    uiState: $uiState,
                    token: token
                )
            }
        }
    }
}
