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
                TodoView(token: token)
            } else {
                LoginView(viewModel: loginViewModel, coordinator: coordinator)
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
