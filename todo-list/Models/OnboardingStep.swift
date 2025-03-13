//
//  OnboardingStep.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

enum OnboardingStep: String, Identifiable {
    case createTodo
    case createCategory
    case finished
    
    var id: String { rawValue }
}
