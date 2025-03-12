//
//  MainTodoContent.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct MainTodoContent: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var uiState: TodoUIState
    let token: String
    let onDeleteTodos: () -> Void
    
    var body: some View {
        VStack {
            CategoryChipsView(
                selectedCategory: $viewModel.selectedCategory,
                showAddCategorySheet: $uiState.showAddCategorySheet,
                categories: viewModel.categories
            )
            
            TodoListContent(
                viewModel: viewModel,
                uiState: $uiState,
                token: token
            )
        }
        .padding(.top, 20)
        .navigationTitle("Todo List")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(ToolbarModifier(
            hideCompleted: $uiState.hideCompleted,
            newTodoClicked: $uiState.newTodoClicked,
            editMode: $uiState.editMode,
            onDelete: onDeleteTodos
        ))
        .refreshable { viewModel.fetchCategories(token: token) }
        .sheet(isPresented: $uiState.showAddCategorySheet) {
            AddCategoryView(viewModel: viewModel, token: token)
                .presentationDetents([.height(200)])
        }
    }
}
