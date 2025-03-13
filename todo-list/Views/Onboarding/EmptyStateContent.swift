//
//  EmptyStateContent.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct EmptyStateContent: View {
    @ObservedObject var onboardingState: OnboardingState
    @ObservedObject var viewModel: TodoViewModel
    let token: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to your Todo App!")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Let's get started by creating your first todo")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Get Started") {
                onboardingState.step = .createTodo
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(item: $onboardingState.step) { step in
            NavigationView {
                OnboardingStepView(
                    step: step,
                    onboardingState: onboardingState,
                    viewModel: viewModel,
                    token: token
                )
            }
        }
    }
}
