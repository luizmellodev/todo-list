//
//  RegisterView.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//


//
//  RegisterView.swift
//  todo-list
//
//  Created by Luiz Mello on 30/01/25.
//

import SwiftUI

struct RegisterView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var name = ""
    @ObservedObject var viewModel: RegisterViewModel

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.register(username: username, password : password, name: name)
            }) {
                Text("Register")
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
        }
        .padding()
    }
}
