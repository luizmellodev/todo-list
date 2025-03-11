//
//  AddTodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/12/24.
//

import SwiftUI

struct AddTodoView: View {
    var token: String
    @Binding var textFieldText: String
    @Binding var selectedCategory: Category?
    
    @ObservedObject var viewModel: TodoViewModel
    
    var isTextEmpty: Bool { textFieldText.isEmpty }
    
    var body: some View {
        HStack {
            TextField("Add new todo item", text: $textFieldText)
            
            Spacer()
            Button(action: addTodo) {
                Image(systemName: "checkmark.square.fill")
                    .font(.title)
                    .padding(3)
                    .foregroundStyle(isTextEmpty ? .gray : .green)
            }
            .disabled(isTextEmpty)
        }
        .onSubmit(addTodo)
        
        if !isTextEmpty && selectedCategory == nil {
            Text("Select at least one category")
                .foregroundStyle(.red)
                .font(.caption2)
                .opacity(selectedCategory != nil ? 0 : 1)
        }
    }
    
    private func addTodo() {
        guard let category = selectedCategory, !textFieldText.isEmpty else { return }
        
        viewModel.createTodo(content: textFieldText, completed: false, categoryId: category.id, token: token)
        
        textFieldText = ""
        selectedCategory = nil
    }
}

#Preview {
    let viewModel = TodoViewModel()
    
    AddTodoView(token: "", textFieldText: .constant("sadasd"), selectedCategory: .constant(.init(id: "321", name: "Category", todos: [], createdAt: "")), viewModel: viewModel)
}
