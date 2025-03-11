//
//  ToolbarButtons.swift
//  todo-list
//
//  Created by Luiz Mello on 08/02/25.
//

import SwiftUI

struct ToolbarModifier: ViewModifier {
    @Binding var hideCompleted: Bool
    @Binding var newTodoClicked: Bool
    @Binding var editMode: EditMode
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleHideCompleted) {
                        Text(hideCompleted ? "Show All" : "Hide Completed")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleEditMode) {
                          Text(editMode == .active ? "Done" : "Edit")
                      }                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: toggleNewTodo) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 42))
                    }
                }
            }
    }
    
    private func toggleEditMode() {
        withAnimation {
            editMode = editMode == .active ? .inactive : .active
        }
    }
    private func toggleHideCompleted() {
        withAnimation {
            hideCompleted.toggle()
        }
    }
    
    private func toggleNewTodo() {
        withAnimation {
            newTodoClicked.toggle()
        }
    }
}
