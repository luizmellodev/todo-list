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
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Chip(categories.isEmpty ? "Add your first category" : "Add", isSelected: true) {
                    showAddCategorySheet.toggle()
                }
                .padding(.horizontal, 5)
                
                ForEach(categories.reversed()) { category in
                    Chip(category.name, isSelected: selectedCategory == category) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
