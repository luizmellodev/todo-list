//
//  ContentView.swift
//  todo-list
//
//  Created by Luiz Mello on 03/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @AppStorage("access_token") private var token: String = ""
    @StateObject private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            switch loginViewModel.state {
            case .loggedIn:
                TodoView(token: token)
            case .error:
                LoginView(coordinator: coordinator, viewModel: loginViewModel)
            default:
                LoginView(coordinator: coordinator, viewModel: loginViewModel)
            }
        }
        .onAppear {
            if let savedToken = loginViewModel.getToken() {
                loginViewModel.verifyToken(token: savedToken)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
