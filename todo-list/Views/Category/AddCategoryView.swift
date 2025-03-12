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
        VStack {
            Text("Add Category")
                .font(.title2)
                .bold()
                .padding()
            
            TextField("Category Name", text: $categoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Add") {
                if !categoryName.isEmpty {
                    viewModel.createCategory(name: categoryName, token: token, completion: {_ in })
                    dismiss()
                }
            }
            .buttonStyle(.automatic)
            
            Spacer()
        }
        .padding()
    }
}
