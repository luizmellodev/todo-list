//
//  OnboardingState.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

class OnboardingState: ObservableObject {
    @Published var step: OnboardingStep?
    @Published var pendingTodo: PendingTodo?
    @Published var tempCategoryId: String?
}
