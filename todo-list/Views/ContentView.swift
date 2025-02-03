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
            if loginViewModel.isLoggedIn == true {
                TodoView(token: token)

            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
        .onChange(of: loginViewModel.isLoggedIn, { oldValue, newValue in
            coordinator.navigateTo(.login)
        })
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
