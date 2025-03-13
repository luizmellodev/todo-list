//
//  CategoryChipsView.swift
//  todo-list
//
//  Created by Luiz Mello on 08/02/25.
//

import SwiftUI

struct CategoryChipsView: View {
    @Binding var selectedCategory: Category?
    @Binding var showAddCategorySheet: Bool
    let categories: [Category]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Button(action: { showAddCategorySheet.toggle() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .imageScale(.small)
                            Text(categories.isEmpty ? "Add your first category" : "New Category")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.leading)
                    
                    ForEach(categories.reversed()) { category in
                        Button(action: { selectedCategory = selectedCategory == category ? nil : category }) {
                            Text(category.name)
                                .font(.subheadline)
                                .foregroundStyle(selectedCategory == category ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedCategory == category ? Color.blue : Color(UIColor.secondarySystemBackground))
                                )
                                .animation(.spring(duration: 0.3), value: selectedCategory == category)
                        }
                        .id(category.id)
                    }
                    
                    Spacer(minLength: 16)
                }
            }
            .scrollDisabled(false)
            .frame(height: 50)
        }
        .background(Color(UIColor.systemBackground))
    }
}
