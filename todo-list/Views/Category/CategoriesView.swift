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
                SearchBar()
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
                            categoryCard(for: category)
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
    
    @ViewBuilder
    private func SearchBar() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            
            TextField("Search categories", text: $searchText)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 15)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 12)
        )
    }
    
    @ViewBuilder
    private func categoryCard(for category: Category) -> some View {
        ZStack {
            if selectedCategory?.id == category.id && animateView {
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
                    .matchedGeometryEffect(id: category.id, in: animation)
                    .overlay {
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
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 4) {
                                    Image(systemName: "checklist")
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Text("\(category.todos.count) tasks")
                                        .font(.callout)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                                
                                let pendingCount = category.todos.filter { $0?.completed == false }.count
                                let completedCount = category.todos.filter { $0?.completed == true }.count
                                
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
                        .padding(15)
                    }
            }
        }
        .frame(height: 180)
    }
}
