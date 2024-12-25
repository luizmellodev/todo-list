//
//  AddTodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/12/24.
//


import SwiftUI

struct AddTodoView: View {
    @Binding var textFieldText: String
    @Binding var selectedCategory: Category?
    @ObservedObject var viewModel: TodoViewModel
    var token: String
    
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
                print("Please select a category")
                return
            }
            viewModel.createTodo(content: textFieldText, completed: false, categoryId: category.id, token: token)
            textFieldText = ""
            selectedCategory = nil
        }
    }
}
