//
//  ContentView.swift
//  todo-list
//
//  Created by Luiz Mello on 03/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var coordinator = NavigationCoordinator()
    
    @AppStorage("access_token") private var token: String = ""
    
    var body: some View {
        NavigationStack {
            if loginViewModel.state == .loggedIn {
                TodoView(loginViewModel: loginViewModel, token: token, coordinator: coordinator)
                    .navigationBarBackButtonHidden(true)
                    .onChange(of: loginViewModel.state) { _, newValue in
                        if newValue == .loggedOut {
                            coordinator.resetNavigation()
                        }
                    }
            } else {
                LoginView(viewModel: loginViewModel, coordinator: coordinator)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            if let savedToken = loginViewModel.getToken() {
                loginViewModel.verifyToken(token: savedToken)
            } else {
                loginViewModel.state = .loggedOut
            }
        }
    }
}

// Your previews remain the same

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
