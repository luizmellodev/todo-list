//
//  ProgressStats.swift
//  todo-list
//
//  Created by Luiz Mello on 17/03/25.
//

import SwiftUI

struct ProgressStats: View {
    let category: Category
    
    private var pendingCount: Int {
        category.todos.filter { $0?.completed == false }.count
    }
    
    private var completedCount: Int {
        category.todos.filter { $0?.completed == true }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.white.opacity(0.3))
                    
                    if category.todos.count > 0 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.white)
                            .frame(width: geometry.size.width * CGFloat(completedCount) / CGFloat(category.todos.count))
                    }
                }
            }
            .frame(height: 4)
            
            Text("\(pendingCount) pending, \(completedCount) completed")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
