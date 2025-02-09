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
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleHideCompleted) {
                        Text(hideCompleted ? "Show All" : "Hide Completed")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: toggleNewTodo) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 42))
                    }
                }
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
