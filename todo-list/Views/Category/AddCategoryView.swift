//
//  AddCategoryView.swift
//  todo-list
//
//  Created by Luiz Mello on 06/02/25.
//

import SwiftUI

struct AddCategoryView: View {
    @State private var categoryName = ""
    @Environment(\.dismiss) var dismiss
    var viewModel: TodoViewModel
    let token: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Category")
                .font(.title3.bold())
                .foregroundStyle(.primary)
            
            TextField("Category name", text: $categoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: addCategory) {
                Text("Create")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(categoryName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    )
            }
            .disabled(categoryName.isEmpty)
            .animation(.spring(duration: 0.3), value: categoryName.isEmpty)
        }
        .padding(24)
    }
    
    private func addCategory() {
        if !categoryName.isEmpty {
            viewModel.createCategory(name: categoryName, token: token, completion: {_ in })
            dismiss()
        }
    }
}
