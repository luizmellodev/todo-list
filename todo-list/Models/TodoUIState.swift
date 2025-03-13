//
//  TodoUIState.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct TodoUIState {
    var newTodoClicked: Bool = false
    var textFieldText: String = ""
    var editMode: EditMode = .inactive
    var textFieldUpdates: [String: String] = [:]
    var hideCompleted = false
    var showAddCategorySheet = false
    var selectedTodoIDs: Set<String> = []
}
