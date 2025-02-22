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
    
    @AppStorage("todos", store: UserDefaults(suiteName: "group.luizmello.todolist")) private var todosData: Data?
    @Environment(\.scenePhase) private var scenePhase
    
    let token: String
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .requestSucceeded:
                contentView
            case .requestFailed, .emptyResult:
                Text("Request failed.")
            default:
                LoadingView()
            }
        }
        .onAppear { syncData() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                syncData()
            }
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
        .modifier(ToolbarModifier(hideCompleted: $hideCompleted, newTodoClicked: $newTodoClicked, editMode: $editMode))
        .refreshable { viewModel.fetchCategories(token: token) }
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
        .sheet(isPresented: $newTodoClicked) {
            AddTodoView(
                token: token,
                textFieldText: $textFieldText,
                selectedCategory: $viewModel.selectedCategory,
                viewModel: viewModel
            ).padding(.horizontal).presentationDetents([.height(100)])
        }
    }

    private func hasVisibleTodos(in category: Category) -> Bool {
        return category.todos.compactMap { $0 }.filter { !hideCompleted || !$0.completed }.count > 0
    }
}

extension TodoView {
    private func syncData() {
        viewModel.fetchCategories(token: token)
        
        let storedTodos = fetchTodosFromStorage()
        
        if shouldSyncWithBackend(storedTodos) {
            Logger.info("🔄 Enviando dados do widget para o backend...")
            storedTodos.forEach { todo in
                viewModel.updateTodo(
                    id: todo.id,
                    content: todo.content,
                    completed: todo.completed,
                    categoryId: todo.categoryId,
                    token: token
                )
            }
        }
    }
    
    
    private func shouldSyncWithBackend(_ storedTodos: [Todo]) -> Bool {
        let incompleteTodos = viewModel.categories.flatMap { $0.todos.compactMap { $0 } }
            .filter { !$0.completed }
        
        let lastSevenTodos = Array(incompleteTodos.prefix(7))

        let isDifferent = !lastSevenTodos.allSatisfy { storedTodo in
            storedTodos.contains { $0.id == storedTodo.id && $0.completed == storedTodo.completed }
        }
        
        return isDifferent
    }

    private func fetchTodosFromStorage() -> [Todo] {
        if let data = todosData, let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            return decoded
        }
        return []
    }
}
