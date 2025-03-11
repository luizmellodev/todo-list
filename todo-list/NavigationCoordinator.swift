//
//  NavigationCoordinator.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//


import SwiftUI

class NavigationCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    enum Destination: Hashable {
        case login
        case register
        case todoList
    }
    
    func navigateTo(_ destination: Destination) {
        switch destination {
        case .login:
            navigationPath.append(Destination.login)
        case .register:
            navigationPath.append(Destination.register)
        case .todoList:
            navigationPath.append(Destination.todoList)
        }
    }
    
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func resetNavigation() {
        navigationPath.removeLast()
    }
}
