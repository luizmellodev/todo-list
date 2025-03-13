//
//  OnboardingStepView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct OnboardingStepView: View {
    let step: OnboardingStep
    @ObservedObject var onboardingState: OnboardingState
    @ObservedObject var viewModel: TodoViewModel
    let token: String
    
    var body: some View {
        Group {
            switch step {
            case .createTodo:
                CreateTodoView { todoContent in
                    onboardingState.pendingTodo = PendingTodo(
                        content: todoContent,
                        completed: false
                    )
                    onboardingState.step = .createCategory
                }
            case .createCategory:
                CreateCategoryView(viewModel: viewModel, token: token) { categoryId in
                    if let todo = onboardingState.pendingTodo {
                        viewModel.createTodo(
                            content: todo.content,
                            completed: todo.completed,
                            categoryId: categoryId,
                            token: token
                        )
                    }
                    onboardingState.step = .finished
                }
            case .finished:
                OnboardingFinishedView {
                    onboardingState.step = nil
                    onboardingState.pendingTodo = nil
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
