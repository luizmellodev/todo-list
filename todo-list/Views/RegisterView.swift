//
//  RegisterView.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var name = ""
    @ObservedObject var viewModel: RegisterViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var formOffset: CGFloat = 400
    @State private var showForm = false
    @State private var isUsernameFocused = false
    @State private var isNameFocused = false
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
            
            VStack(spacing: 25) {
                Text("Create Account")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(showForm ? 1 : 0)
                    .offset(y: showForm ? 0 : -30)
                
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
                    }
                    
                    ZStack(alignment: .leading) {
                        if name.isEmpty && !isNameFocused {
                            Text("Name")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 20)
                        }
                        TextField("", text: $name)
                            .textFieldStyle(ModernTextFieldStyle())
                            .onTapGesture {
                                isNameFocused = true
                            }
                    }
                    
                    ZStack(alignment: .leading) {
                        if password.isEmpty && !isPasswordFocused {
                            Text("Password")
                                .foregroundColor(.white.opacity(0.7))
                                .autocapitalization(.none)
                                .padding(.leading, 20)
                        }
                        SecureField("", text: $password)
                            .textFieldStyle(ModernTextFieldStyle())
                            .onTapGesture {
                                isPasswordFocused = true
                            }
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            viewModel.register(username: username, password: password, name: name)
                        }
                    }) {
                        Text("Create Account")
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
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                    .padding(.top)
                }
                .offset(x: formOffset)
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            animateEntrance()
        }
        .onReceive(viewModel.$state) { newState in
            if newState == .loggedIn {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func animateEntrance() {
        withAnimation(.spring(dampingFraction: 0.7).delay(0.3)) {
            formOffset = 0
            showForm = true
        }
    }
}
