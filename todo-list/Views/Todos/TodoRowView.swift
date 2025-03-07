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
    @Binding var selectedTodoIDs: Set<String>
    
    @State private var isEditing = false
    var token: String
    
    init(todo: Binding<Todo?>, editMode: Binding<EditMode>, textUpdate: Binding<[String: String]>, selectedTodoIDs: Binding<Set<String>>, token: String) {
        self._todo = todo
        self._editMode = editMode
        self._textUpdate = textUpdate
        self._selectedTodoIDs = selectedTodoIDs
        self._localText = State(initialValue: textUpdate.wrappedValue[todo.wrappedValue?.id ?? ""] ?? todo.wrappedValue?.content ?? "")
        self.token = token
    }
    
    var body: some View {
        if let todo = todo {
            HStack {
                if editMode == .inactive {
                    Button(action: {
                        withAnimation {
                            viewModel.updateTodo(id: todo.id, content: todo.content, completed: !todo.completed, categoryId: todo.categoryId, token: token)
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
                    Button(action: {
                        if selectedTodoIDs.contains(todo.id) {
                            selectedTodoIDs.remove(todo.id)
                        } else {
                            selectedTodoIDs.insert(todo.id)
                        }
                    }) {
                        Image(systemName: selectedTodoIDs.contains(todo.id) ? "checkmark.square.fill" : "square")
                            .font(.title)
                            .padding(3)
                            .contentShape(Rectangle())
                            .foregroundStyle(.blue)
                    }
                    .contentTransition(.symbolEffect(.replace))
                    
                    if isEditing {
                        TextField("", text: $localText, onCommit: submitEdit)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 5)
                            .onAppear { localText = todo.content }
                            .onChange(of: editMode) { _, newValue in
                                if newValue == .inactive { isEditing = false }
                            }
                            .onSubmit(submitEdit)
                            .onTapGesture { }
                            .onDisappear { isEditing = false }
                    } else {
                        Text(todo.content)
                            .strikethrough(todo.completed)
                            .foregroundStyle(todo.completed ? .gray : .primary)
                            .padding(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedTodoIDs.contains(todo.id) ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                withAnimation {
                                    if selectedTodoIDs.contains(todo.id) {
                                        selectedTodoIDs.remove(todo.id)
                                    } else {
                                        selectedTodoIDs.insert(todo.id)
                                    }
                                }
                            }
                            .onLongPressGesture {
                                withAnimation {
                                    isEditing = true
                                }
                            }
                    }
                }
            }
            .foregroundStyle(selectedTodoIDs.contains(todo.id) ? Color.blue.opacity(0.3) : Color.clear)
        }
    }
    
    private func submitEdit() {
        if let todo = todo {
            viewModel.updateTodo(id: todo.id, content: localText, completed: todo.completed, categoryId: todo.categoryId, token: token)
        }
        isEditing = false
    }
}
