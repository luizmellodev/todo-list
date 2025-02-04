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
    @Binding var isCategoryEmpty: Bool
    
    @ObservedObject var viewModel: TodoViewModel
    
    
    var body: some View {
        HStack {
            TextField("Add new todo item", text: $textFieldText)
            
            Picker("", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .onSubmit {
            guard let category = selectedCategory else {
                self.isCategoryEmpty = true
                return
            }
            viewModel.createTodo(content: textFieldText, completed: false, categoryId: category.id, token: token)
            textFieldText = ""
            selectedCategory = nil
        }
        .onChange(of: textFieldText) { oldValue, newValue in
            withAnimation {
                if isCategoryEmpty {
                    isCategoryEmpty = false
                }
            }
        }
    }
}

#Preview {
    let viewModel = TodoViewModel()
    
    AddTodoView(token: "", textFieldText: .constant("sadasd"), selectedCategory: .constant(.init(id: "321", name: "Category", todos: [], createdAt: "")), isCategoryEmpty: .constant(false), viewModel: viewModel)
}
