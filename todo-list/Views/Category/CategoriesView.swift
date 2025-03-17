import SwiftUI

struct CategoriesView: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var animateView = false
    @Namespace private var animation
    
    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 20) {
                SearchBar(searchText: $searchText)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                    ForEach(filteredCategories) { category in
                        CategoryCell {
                            guard selectedCategory == nil else { return }
                            selectedCategory = category
                            withAnimation(.smooth(duration: 0.3)) {
                                animateView = true
                            }
                        } content: {
                            CategoryCard(
                                category: category,
                                namespace: animation,
                                isSelected: selectedCategory?.id == category.id,
                                animateView: animateView
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            Color.gray.opacity(0.1)
                .ignoresSafeArea()
        )
        .overlay {
            if let selectedCategory, animateView {
                CategoryDetailView(
                    category: selectedCategory,
                    animation: animation,
                    show: $animateView,
                    selectedCategory: $selectedCategory
                )
                .ignoresSafeArea(.container, edges: .top)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 50)),
                    removal: .opacity.combined(with: .offset(y: 50))
                ))
            }
        }
    }
    
    private var filteredCategories: [Category] {
        if searchText.isEmpty {
            return viewModel.categories
        }
        return viewModel.categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
