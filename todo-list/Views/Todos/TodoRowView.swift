//
//  TodoRowView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/12/24.
//

import SwiftUI

struct TodoRowView: View {
    @Binding var todo: Todo?
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var localText: String
    @Binding var editMode: EditMode
    @Binding var textUpdate: [String: String]
    
    var token: String
    
    init(todo: Binding<Todo?>, editMode: Binding<EditMode>, textUpdate: Binding<[String: String]>, token: String) {
        self._todo = todo
        self._editMode = editMode
        self._textUpdate = textUpdate
        self._localText = State(initialValue: textUpdate.wrappedValue[todo.wrappedValue?.id ?? ""] ?? todo.wrappedValue?.content ?? "")
        self.token = token
    }
    
    var body: some View {
        if let todo = todo {
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
                    .contentTransition(.symbolEffect(.replace))
                    
                    Text(todo.content)
                        .strikethrough(todo.completed)
                        .foregroundStyle(todo.completed ? .gray : .primary)
                } else {
                    TextField(todo.content, text: $localText)
                        .onChange(of: localText) { _, newValue in
                            textUpdate[todo.id] = newValue
                        }
                    
                        .onSubmit {
                            withAnimation {
                                viewModel.updateTodo(id: todo.id, content: localText, username: "", completed: todo.completed, categoryId: todo.categoryId, token: token)
                            }
                        }
                }
            }
        }
    }
}
