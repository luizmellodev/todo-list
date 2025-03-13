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
    
    @State private var isGridView = false
    
    var body: some View {
        ZStack {
            if isGridView {
                CategoriesView(viewModel: viewModel)
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 15) {
                        CategoryChipsView(
                            selectedCategory: $viewModel.selectedCategory,
                            showAddCategorySheet: $uiState.showAddCategorySheet,
                            categories: viewModel.categories
                        )
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.gray.opacity(0.2))
                    }
                    .background(
                        Color(UIColor.systemBackground)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 5)
                    )
                    
                    // Content
                    TodoListContent(
                        viewModel: viewModel,
                        uiState: $uiState,
                        token: token
                    )
                }
            }
            
            DockMenu(
                editMode: $uiState.editMode,
                showingNewTodo: $uiState.newTodoClicked,
                isGridView: $isGridView,
                onDelete: onDeleteTodos
            )
        }
        .padding(.top, 20)
        .navigationTitle("Todo List")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { viewModel.fetchCategories(token: token) }
        .sheet(isPresented: $uiState.showAddCategorySheet) {
            AddCategoryView(viewModel: viewModel, token: token)
                .presentationDetents([.height(200)])
        }
    }
}
