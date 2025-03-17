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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(category.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "folder.fill")
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            CategoryCardStats(category: category)
        }
        .padding(15)
    }
}
