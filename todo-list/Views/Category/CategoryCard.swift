//
//  CategoryCard.swift
//  todo-list
//
//  Created by Luiz Mello on 17/03/25.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    let namespace: Namespace.ID
    let isSelected: Bool
    let animateView: Bool
    
    var body: some View {
        ZStack {
            if isSelected && animateView {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.clear)
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.blue
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .matchedGeometryEffect(id: category.id, in: namespace)
                    .overlay {
                        CategoryCardContent(category: category)
                    }
            }
        }
        .frame(height: 180)
    }
}
