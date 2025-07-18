//
//  CategoryCardContent.swift
//  todo-list
//
//  Created by Luiz Mello on 17/03/25.
//

import SwiftUI

struct CategoryCardContent: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                Text(category.todos.isEmpty ? "Categoria vazia" : "\(category.todos.count) todos")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
        }
        .padding()
    }
}
