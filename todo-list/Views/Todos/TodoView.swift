//
//  TodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 13/01/25.
//

import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    @StateObject private var onboardingState = OnboardingState()
    @State private var uiState = TodoUIState()
    @AppStorage("todos", store: UserDefaults(suiteName: "group.luizmello.todolist")) private var todosData: Data?
    @Environment(\.scenePhase) private var scenePhase
    
    let token: String
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .requestSucceeded:
                mainContent
            case .requestFailed, .emptyResult:
                Text("Request failed.")
            default:
                LoadingView()
            }
        }
        .onAppear { syncData() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { syncData() }
        }
    }
}

// MARK: - View Extensions
private extension TodoView {
    @ViewBuilder
    var mainContent: some View {
        if viewModel.categories.isEmpty {
            EmptyStateContent(
                onboardingState: onboardingState,
                viewModel: viewModel,
                token: token
            )
        } else {
            MainTodoContent(
                viewModel: viewModel,
                uiState: $uiState,
                token: token,
                onDeleteTodos: deleteSelectedTodos
            )
        }
    }
    
    private func deleteSelectedTodos() {
        viewModel.deleteTodos(ids: Array(uiState.selectedTodoIDs), token: token)
        uiState.selectedTodoIDs.removeAll()
    }
}


extension TodoView {
    func syncData() {
        viewModel.fetchCategories(token: token)
        syncWidgetData()
    }
    
    func syncWidgetData() {
        let storedTodos = fetchTodosFromStorage()
        if shouldSyncWithBackend(storedTodos) {
            Logger.info("🔄 Enviando dados do widget para o backend...")
            updateStoredTodos(storedTodos)
        }
    }
    
    func shouldSyncWithBackend(_ storedTodos: [Todo]) -> Bool {
        let incompleteTodos = viewModel.categories
            .flatMap { $0.todos.compactMap { $0 } }
            .filter { !$0.completed }
            .prefix(7)
        
        return !incompleteTodos.allSatisfy { storedTodo in
            storedTodos.contains { $0.id == storedTodo.id && $0.completed == storedTodo.completed }
        }
    }
    
    func updateStoredTodos(_ todos: [Todo]) {
        todos.forEach { todo in
            viewModel.updateTodo(
                id: todo.id,
                content: todo.content,
                completed: todo.completed,
                categoryId: todo.categoryId,
                token: token
            )
        }
    }
    
    func fetchTodosFromStorage() -> [Todo] {
        guard let data = todosData,
              let decoded = try? JSONDecoder().decode([Todo].self, from: data)
        else { return [] }
        return decoded
    }
}
