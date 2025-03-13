//
//  LoginView.swift
//  todo-list
//
//  Created by Luiz Mello on 28/11/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel
    @ObservedObject var coordinator: NavigationCoordinator
    
    @State private var username = ""
    @State private var password = ""
    @State private var isShowingRegisterView = false
    @State private var isAnimating = false
    @State private var showingFields = false
    @State private var logoOffset: CGFloat = -100
    @State private var fieldsOffset: CGFloat = 400
    @State private var isUsernameFocused = false
    @State private var isPasswordFocused = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.1, green: 0.1, blue: 0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Todo List")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .offset(y: logoOffset)
                .opacity(isAnimating ? 1 : 0)
                
                if viewModel.state == .loggedIn {
                    Text("Bem-vindo(a)")
                        .font(.title2)
                        .foregroundColor(.white)
                        .onAppear {
                            coordinator.navigateTo(.todoList)
                        }
                } else {
                    VStack(spacing: 20) {
                        ZStack(alignment: .leading) {
                            if username.isEmpty && !isUsernameFocused {
                                Text("Username")
                                    .foregroundColor(.white.opacity(0.7))
                                    .autocapitalization(.none)
                                    .padding(.leading, 20)
                            }
                            TextField("", text: $username)
                                .textFieldStyle(ModernTextFieldStyle())
                                .autocapitalization(.none)
                                .onTapGesture {
                                    isUsernameFocused = true
                                }
                                .onSubmit {
                                    isUsernameFocused = false
                                }
                        }
                        
                        ZStack(alignment: .leading) {
                            if password.isEmpty && !isPasswordFocused {
                                Text("Password")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.leading, 20)
                            }
                            SecureField("", text: $password)
                                .textFieldStyle(ModernTextFieldStyle())
                                .onTapGesture {
                                    isPasswordFocused = true
                                }
                                .onSubmit {
                                    isPasswordFocused = false
                                }
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                viewModel.login(username: username, password: password)
                            }
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
                        }
                        
                        if case .error(let message) = viewModel.state {
                            Text(message)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .offset(x: fieldsOffset)
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowingRegisterView = true
                        }
                    }) {
                        Text("Create an account")
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                    .padding(.top)
                    .opacity(showingFields ? 1 : 0)
                }
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            animateEntrance()
        }
        .sheet(isPresented: $isShowingRegisterView) {
            RegisterView(viewModel: createConfiguredRegisterVM())
        }
        .onChange(of: viewModel.state) { oldValue, newValue in
            if newValue == .loggedIn {
                coordinator.navigateTo(.todoList)
            }
        }
    }
    
    private func animateEntrance() {
        withAnimation(.spring(dampingFraction: 0.7).delay(0.3)) {
            logoOffset = 0
            isAnimating = true
        }
        
        withAnimation(.spring(dampingFraction: 0.7).delay(0.5)) {
            fieldsOffset = 0
            showingFields = true
        }
    }
    
    private func createConfiguredRegisterVM() -> RegisterViewModel {
        let vm = RegisterViewModel()
        
        vm.onSuccessfulRegister = { [weak viewModel] username, password in
            viewModel?.login(username: username, password: password)
        }
        
        return vm
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .accentColor(.white)
    }
}
