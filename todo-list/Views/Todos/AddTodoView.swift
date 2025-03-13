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
    
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var isTextEmpty: Bool { textFieldText.isEmpty }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 12) {
                TextField("Add new todo item", text: $textFieldText)
                    .textFieldStyle(CustomTextFieldStyle())
                    .focused($isTextFieldFocused)
                
                Button(action: addTodo) {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(isTextEmpty ? .gray : .blue)
                }
                .disabled(isTextEmpty)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTextEmpty)
            }
            
            if !isTextEmpty && selectedCategory == nil {
                Text("Select at least one category")
                    .foregroundStyle(.red)
                    .font(.caption2)
                    .opacity(selectedCategory != nil ? 0 : 1)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .onAppear {
            isTextFieldFocused = true
        }
        .onSubmit(addTodo)
    }
    
    private func addTodo() {
        guard let category = selectedCategory, !textFieldText.isEmpty else { return }
        
        viewModel.createTodo(content: textFieldText, completed: false, categoryId: category.id, token: token)
        
        withAnimation {
            textFieldText = ""
            selectedCategory = nil
            dismiss()
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primary.opacity(0.05))
            )
    }
}

#Preview {
    let viewModel = TodoViewModel()
    
    AddTodoView(token: "", textFieldText: .constant("sadasd"), selectedCategory: .constant(.init(id: "321", name: "Category", todos: [], createdAt: "")), viewModel: viewModel)
}
