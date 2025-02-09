//
//  LoginView.swift
//  todo-list
//
//  Created by Luiz Mello on 28/11/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isShowingRegisterView = false
    
    @ObservedObject private var coordinator: NavigationCoordinator
    @ObservedObject var viewModel: LoginViewModel

    public init(username: String = "", password: String = "", isShowingRegisterView: Bool = false, coordinator: NavigationCoordinator, viewModel: LoginViewModel) {
        self.username = username
        self.password = password
        self.isShowingRegisterView = isShowingRegisterView
        self.coordinator = coordinator
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.login(username: username, password: password)
            }) {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Create an account") {
                isShowingRegisterView = true
            }
            .padding()
            .foregroundColor(.blue)
            .sheet(isPresented: $isShowingRegisterView) {
                RegisterView(viewModel: RegisterViewModel())
                    .environmentObject(coordinator)
            }
        }
        .padding()
    }
}
