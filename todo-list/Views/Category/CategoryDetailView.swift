import SwiftUI

struct CategoryDetailView: View {
    let category: Category
    var animation: Namespace.ID
    @Binding var show: Bool
    @Binding var selectedCategory: Category?
    @State private var animateContent = false
    
    var body: some View {
        GeometryReader { _ in
            
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: animateContent ? 0 : 15)
                    .fill(Color.blue.gradient)
                    .matchedGeometryEffect(id: category.id, in: animation)
                    .frame(height: 160)
                    .overlay {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(category.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Button {
                                    withAnimation(.smooth(duration: 0.3)) {
                                        animateContent = false
                                        show = false
                                        selectedCategory = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            Text("\(category.todos.count) tasks")
                                .font(.callout)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding()
                    }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(category.todos.compactMap { $0 }) { todo in
                            TodoItemRow(todo: todo)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.background)
        }
        .onAppear {
            withAnimation(.smooth(duration: 0.3).delay(0.05)) {
                animateContent = true
            }
        }
    }
}

@ViewBuilder
func TodoItemRow(todo: Todo) -> some View {
    HStack(spacing: 12) {
        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(todo.completed ? .green : .gray)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(todo.content)
                .font(.callout)
                .strikethrough(todo.completed)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(.gray.opacity(0.1), in: .rect(cornerRadius: 10))
}

#Preview {
    ContentView()
}
