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
                LogoHeader()
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
                    LoginForm(
                        username: $username,
                        password: $password,
                        isUsernameFocused: $isUsernameFocused,
                        isPasswordFocused: $isPasswordFocused,
                        onLoginTap: {
                            withAnimation(.spring()) {
                                viewModel.login(username: username, password: password)
                            }
                        },
                        loginState: viewModel.state
                    )
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
