//
//  CreateCategoryView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct CreateCategoryView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var categoryName = ""
    @State private var isLoading = false
    let token: String
    let nextStep: (String) -> Void
    
    var body: some View {
        VStack {
            Text("Create a Category")
                .font(.title)
            Text("Great! Now let's organize your todo by creating a category for it.")
                .padding()
                .multilineTextAlignment(.center)
            
            TextField("Enter category name", text: $categoryName)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            if isLoading {
                ProgressView()
            } else {
                Button("Save and Finish") {
                    isLoading = true
                    viewModel.createCategory(name: categoryName, token: token) { categoryId in
                        isLoading = false
                        if let id = categoryId {
                            nextStep(id)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(categoryName.isEmpty)
            }
        }
        .padding()
    }
}
