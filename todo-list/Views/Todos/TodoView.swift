//
//  TodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 13/01/25.
//

import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    
    @State private var newTodoClicked: Bool = false
    @State private var textFieldText: String = ""
    @State private var editMode: EditMode = .inactive
    @State private var textFieldUpdates: [String: String] = [:]
    @State private var hideCompleted = false
    @State private var showAddCategorySheet = false
    
    let token: String

    var body: some View {
        switch viewModel.state {
        case .loading:
            LoadingView().onAppear { viewModel.fetchCategories(token: token) }
        case .requestSucceeded:
            contentView
        case .requestFailed, .emptyResult:
            Text("Request failed.")
        default:
            LoadingView().onAppear { viewModel.fetchCategories(token: token) }
        }
    }
    
    private var contentView: some View {
        VStack {
            CategoryChipsView(
                selectedCategory: $viewModel.selectedCategory,
                showAddCategorySheet: $showAddCategorySheet,
                categories: viewModel.categories
            )
            
            displayTodoList()
        }
        .padding(.top, 20)
        .navigationTitle("Todo List")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(ToolbarModifier(hideCompleted: $hideCompleted, newTodoClicked: $newTodoClicked))
        .refreshable { viewModel.fetchCategories(token: token) }
        .onAppear { viewModel.fetchCategories(token: token) }
        .sheet(isPresented: $showAddCategorySheet) {
            AddCategoryView(viewModel: viewModel, token: token).presentationDetents([.height(200)])
        }
    }

    private func displayTodoList() -> some View {
        if let selectedCategory = viewModel.selectedCategory, selectedCategory.todos.isEmpty {
            return AnyView(
                EmptyStateView()
                    .sheet(isPresented: $newTodoClicked) {
                        AddTodoView(
                            token: token,
                            textFieldText: $textFieldText,
                            selectedCategory: $viewModel.selectedCategory,
                            viewModel: viewModel
                        ).padding(.horizontal).presentationDetents([.height(100)])
                    }
            )
        } else {
            return AnyView(todoListView)
        }
    }

    private var todoListView: some View {
        List {
            if newTodoClicked {
                AddTodoView(
                    token: token,
                    textFieldText: $textFieldText,
                    selectedCategory: $viewModel.selectedCategory,
                    viewModel: viewModel
                )
            }

            let filteredCategories = viewModel.selectedCategory != nil ? [viewModel.selectedCategory!] : viewModel.categories

            ForEach(viewModel.categories.indices, id: \.self) { index in
                let category = viewModel.categories[index]

                if hasVisibleTodos(in: category), filteredCategories.contains(where: { $0.id == category.id }) {
                    TodoSection(
                        token: token,
                        textFieldUpdates: $textFieldUpdates,
                        editMode: $editMode,
                        category: $viewModel.categories[index]
                    )
                    .id(category.id)
                    .environmentObject(viewModel)
                }
            }
        }
    }

    private func hasVisibleTodos(in category: Category) -> Bool {
        return category.todos.compactMap { $0 }.filter { !hideCompleted || !$0.completed }.count > 0
    }
}
