//
//  TodoRowView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/12/24.
//


import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    @Binding var editMode: EditMode
    @ObservedObject var viewModel: TodoViewModel
    @Binding var textUpdate: [String: String]
    
    @State private var localText: String
    
    var token: String
    
    init(todo: Todo, editMode: Binding<EditMode>, viewModel: TodoViewModel, textUpdate: Binding<[String: String]>, token: String) {
        self.todo = todo
        self._editMode = editMode
        self.viewModel = viewModel
        self._textUpdate = textUpdate
        self._localText = State(initialValue: textUpdate.wrappedValue[todo.id] ?? todo.content)
        self.token = token
    }
    
    var body: some View {
        HStack {
            if editMode == .inactive {
                Button(action: {
                    withAnimation {
                        viewModel.updateTodo(id: todo.id, content: todo.content, username: todo.username, completed: !todo.completed, categoryId: todo.categoryId, token: token)
                    }
                }) {
                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .padding(3)
                        .contentShape(Rectangle())
                        .foregroundStyle(todo.completed ? .gray : .accentColor)
                }
                
                Text(todo.content)
                    .strikethrough(todo.completed)
                    .foregroundStyle(todo.completed ? .gray : .primary)
            } else {
                TextField(todo.content, text: $localText)
                    .onChange(of: localText) { _, newValue in
                        textUpdate[todo.id] = newValue
                    }
                    .onSubmit {
                        viewModel.updateTodo(id: todo.id, content: localText, username: "", completed: todo.completed, categoryId: todo.categoryId, token: token)
                    }
            }
        }
    }
}
