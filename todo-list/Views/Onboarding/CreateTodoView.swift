//
//  CreateTodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct CreateTodoView: View {
    @State private var todoText = ""
    let onSaveTodo: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Create Your First Todo")
                .font(.title)
            Text("What would you like to do?")
                .padding()
            
            TextField("Enter your todo", text: $todoText)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Continue") {
                onSaveTodo(todoText)
            }
            .buttonStyle(.borderedProminent)
            .disabled(todoText.isEmpty)
        }
        .padding()
    }
}
