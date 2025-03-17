//
//  LoginForm.swift
//  todo-list
//
//  Created by Luiz Mello on 17/03/25.
//

import SwiftUI

struct LoginForm: View {
    @Binding var username: String
    @Binding var password: String
    @Binding var isUsernameFocused: Bool
    @Binding var isPasswordFocused: Bool
    let onLoginTap: () -> Void
    let loginState: DefaultViewState
    
    var body: some View {
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
            
            Button(action: onLoginTap) {
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
            
            if case .error(let message) = loginState {
                Text(message)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
