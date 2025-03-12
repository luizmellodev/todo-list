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
    
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject var coordinator: NavigationCoordinator

    var body: some View {
        VStack {
            if viewModel.state == .loggedIn {
                Text("Bem-vindo(a)")
                    .onAppear {
                        coordinator.navigateTo(.todoList)
                    }
            } else {
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
                    RegisterView(viewModel: createConfiguredRegisterVM())
                }
            }
        }
        .onChange(of: viewModel.state, { oldValue, newValue in
            if newValue == .loggedIn {
                coordinator.navigateTo(.todoList)
            }
        })
        .padding()
    }
    
    private func createConfiguredRegisterVM() -> RegisterViewModel {
        let vm = RegisterViewModel()
        
        vm.onSuccessfulRegister = { [weak viewModel] username, password in
            viewModel?.login(username: username, password: password)
        }
        
        return vm
    }
}
