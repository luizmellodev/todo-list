//
//  TodoRowView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/12/24.
//

import SwiftUI

struct TodoRowView: View {
    @Binding var todo: Todo
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var localText: String
    @Binding var editMode: EditMode
    @Binding var textUpdate: [String: String]
    @Binding var selectedTodoIDs: Set<String>
    
    @State private var isEditing = false
    var token: String
    
    init(todo: Binding<Todo>, editMode: Binding<EditMode>, textUpdate: Binding<[String: String]>, selectedTodoIDs: Binding<Set<String>>, token: String) {
        self._todo = todo
        self._editMode = editMode
        self._textUpdate = textUpdate
        self._selectedTodoIDs = selectedTodoIDs
        self._localText = State(initialValue: textUpdate.wrappedValue[todo.wrappedValue.id] ?? todo.wrappedValue.content)
        self.token = token
    }
    
    var body: some View {
        HStack {
            if editMode == .inactive {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.updateTodo(id: todo.id, content: todo.content, completed: !todo.completed, categoryId: todo.categoryId, token: token)
                    }
                }) {
                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .symbolEffect(.bounce.up.byLayer, options: .speed(1.5), value: todo.completed)
                        .foregroundStyle(todo.completed ? .green : .blue)
                        .contentTransition(.symbolEffect(.replace.downUp))
                }
                .contentTransition(.symbolEffect(.replace))
                
                Text(todo.content)
                    .strikethrough(todo.completed)
                    .foregroundStyle(todo.completed ? .gray : .primary)
                    .animation(.easeInOut(duration: 0.3), value: todo.completed)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(todo.completed ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1))
                    )
            } else {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if selectedTodoIDs.contains(todo.id) {
                            selectedTodoIDs.remove(todo.id)
                        } else {
                            selectedTodoIDs.insert(todo.id)
                        }
                    }
                }) {
                    Image(systemName: selectedTodoIDs.contains(todo.id) ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .symbolEffect(.bounce, options: .speed(1.5), value: selectedTodoIDs.contains(todo.id))
                        .foregroundStyle(.blue)
                        .contentTransition(.symbolEffect(.replace.downUp))
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
                        .transition(.opacity)
                } else {
                    Text(todo.content)
                        .strikethrough(todo.completed)
                        .foregroundStyle(todo.completed ? .gray : .primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTodoIDs.contains(todo.id) ? Color.blue.opacity(0.1) : Color.clear)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if selectedTodoIDs.contains(todo.id) {
                                    selectedTodoIDs.remove(todo.id)
                                } else {
                                    selectedTodoIDs.insert(todo.id)
                                }
                            }
                        }
                        .onLongPressGesture {
                            withAnimation(.spring()) {
                                isEditing = true
                            }
                        }
                }
            }
        }
        .padding(.vertical, 4)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(selectedTodoIDs.contains(todo.id) ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
    
    private func submitEdit() {
        viewModel.updateTodo(id: todo.id, content: localText, completed: todo.completed, categoryId: todo.categoryId, token: token)
        isEditing = false
    }
}
