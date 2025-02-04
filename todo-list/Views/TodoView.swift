import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = TodoViewModel()
    
    @State private var newTodoClicked: Bool = false
    @State private var textFieldText: String = ""
    @State private var selectedCategory: Category?
    @State private var editMode: EditMode = .inactive
    @State private var textFieldUpdates: [String: String] = [:]
    @State private var hideCompleted = false
    @State private var isCategoryEmpty = false

    let token: String
    
    var body: some View {
        switch viewModel.state {
        case .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .onAppear {
                viewModel.fetchCategories(token: token)
            }
        case .requestSucceeded:
            todoListView
                .navigationTitle("Todo List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: EditButton())
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                hideCompleted.toggle()
                            }
                        }) {
                            Text(hideCompleted ? "Show All" : "Hide Completed")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        addButton
                    }
                }
                .refreshable {
                    viewModel.fetchCategories(token: token)
                }
                .onAppear {
                    viewModel.fetchCategories(token: token)
                }
        case .requestFailed, .emptyResult:
            Text("Request failed.")
        default:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }
    
    private var todoListView: some View {
        ScrollViewReader { proxy in
            List {
                if newTodoClicked {
                    AddTodoView(
                        token: token,
                        textFieldText: $textFieldText,
                        selectedCategory: $selectedCategory,
                        isCategoryEmpty: $isCategoryEmpty,
                        viewModel: viewModel
                    )
                    if isCategoryEmpty {
                        Text("Please select one category")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }

                }
                
                ForEach(viewModel.categories.filter { hasVisibleTodos(in: $0) }) { category in
                    Section(header: Text(category.name)) {
                        ForEach(filteredTodos(in: category)) { todo in
                            TodoRowView(
                                todo: todo,
                                editMode: $editMode,
                                viewModel: viewModel,
                                textUpdate: $textFieldUpdates,
                                token: token
                            )
                            .id(todo.id)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteTodos(at: indexSet, in: category, token: token)
                        }
                    }
                    .id(category.id)
                }
            }
        }
    }
    
    private func filteredTodos(in category: Category) -> [Todo] {
        if hideCompleted {
            return category.todos.filter { !$0.completed }
        } else {
            return category.todos
        }
    }
    
    private func hasVisibleTodos(in category: Category) -> Bool {
        return filteredTodos(in: category).count > 0
    }
    
    private var addButton: some View {
        Button(action: {
            withAnimation {
                newTodoClicked.toggle()
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .fontWeight(.light)
                .font(.system(size: 42))
        }
    }
}
