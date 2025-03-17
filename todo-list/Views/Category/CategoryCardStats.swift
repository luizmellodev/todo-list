//
//  CategoryCardStats.swift
//  todo-list
//
//  Created by Luiz Mello on 17/03/25.
//

import SwiftUI

struct CategoryCardStats: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("\(category.todos.count) tasks")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            ProgressStats(category: category)
        }
    }
}
