//
//  TodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 13/01/25.
//

import SwiftUI

struct TodoView: View {
    @AppStorage("todos", store: UserDefaults(suiteName: "group.luizmello.todolist")) private var todosData: Data?
    
    @StateObject private var viewModel = TodoViewModel()
    @ObservedObject var loginViewModel: LoginViewModel
    @StateObject private var onboardingState = OnboardingState()
    
    @State private var uiState = TodoUIState()
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss

    let token: String
    
    @State private var showingMenu = false
    @State private var contentOffset: CGFloat = 50
    @State private var contentOpacity: CGFloat = 0
    
    @ObservedObject var coordinator: NavigationCoordinator

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                LoadingView()
            case .requestSucceeded:
                mainContent
                    .offset(y: contentOffset)
                    .opacity(contentOpacity)
                    .onAppear {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            contentOffset = 0
                            contentOpacity = 1
                        }
                    }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive, action: logout) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.primary)
                }
            }
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
    
    private func logout() {
        loginViewModel.logout(token: token)
        todosData = nil
        coordinator.resetNavigation() 
    }
}
