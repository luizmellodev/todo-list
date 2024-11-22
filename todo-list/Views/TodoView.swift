import SwiftUI

struct TodoView: View {
    @State var textFieldText: String = ""
    @State var newTodoClicked: Bool = false
    @State private var selectedCategory: Category?
    
    @StateObject private var viewModel = CategoriesViewModel()
    
    @State var newTodoClicked: Bool = false
    @State var textFieldText: String = ""
    @State private var selectedCategory: Category?
    @State private var editMode: EditMode = .inactive
    @State private var textFieldUpdates: [String: String] = [:]
    
    var body: some View {
        ScrollViewReader { proxy in
            NavigationView {
                List {
                    if newTodoClicked {
                        AddTodoView
                    }
                    
                    ForEach(viewModel.categories) { category in
                        Section(header: Text(category.name)) {
                            ForEach(category.todos) { todo in
                                TodoRowView(todo: todo, viewModel: viewModel)
                            }
                            .onDelete { indexSet in
                                viewModel.deleteTodos(at: indexSet, in: category)
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteTodos(at: indexSet, in: category)
                        }
                    }
                    
                    ForEach(viewModel.categories) { category in
                        Section(header: Text(category.name)) {
                            ForEach(category.todos) { todo in
                                TodoRowView(
                                    todo: todo,
                                    editMode: $editMode,
                                    viewModel: viewModel,
                                    textUpdate: $textFieldUpdates
                                )
                                .id(todo.id)
                            }
                            .onDelete { indexSet in
                                viewModel.deleteTodos(at: indexSet, in: category)
                            }
                        }
                        .id(category.id)
                    }
                }
                .navigationTitle("Todo List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: EditButton())
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            withAnimation {
                                self.newTodoClicked.toggle()
                                proxy.scrollTo(viewModel.categories.first?.todos.first?.id, anchor: .bottom)
                            }
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                                .fontWeight(.light)
                                .font(.system(size: 42))
                        })
                    }
                }
                .refreshable {
                    viewModel.fetchCategories()
                }
                .onAppear {
                    viewModel.fetchCategories()
                }
                .refreshable {
                    viewModel.fetchCategories()
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        AddTodoButton(proxy: proxy)
                    }
                }
                .navigationTitle("Todo List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: EditButton())
            }
        }
        .onAppear {
            viewModel.fetchCategories()
        }
    }
    
    @ViewBuilder
    private var AddTodoView: some View {
        HStack {
            TextField(text: $textFieldText) {
                Text("Add new todo item")
            }
            
            Picker("", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .onSubmit {
            withAnimation {
                guard let category = selectedCategory else {
                    print("Please select a category")
                    return
                }
                viewModel.createTodo(content: self.textFieldText, completed: false, categoryId: category.id)
                textFieldText.removeAll()
                selectedCategory = nil
            }
        }
    }
    
    @ViewBuilder
    private func AddTodoButton(proxy: ScrollViewProxy) -> some View {
        Button(action: {
            withAnimation {
                if let firstCategoryId = viewModel.categories.first?.id {
                    if !newTodoClicked {
                        proxy.scrollTo(firstCategoryId, anchor: .bottom)
                    }
                }
                self.newTodoClicked.toggle()
            }
        }, label: {
            Image(systemName: "plus.circle.fill")
                .fontWeight(.light)
                .font(.system(size: 42))
        })
    }
}

struct TodoRowView: View {
    let todo: Todo
    @ObservedObject var viewModel: CategoriesViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.updateTodoById(id: todo.id, content: todo.content, completed: !todo.completed, categoryId: todo.categoryId, createdAt: todo.createdAt)
            }, label: {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .padding(3)
                    .contentShape(.rect)
                    .foregroundStyle(todo.completed ? .gray : .accentColor)
                    .contentTransition(.symbolEffect(.replace))
            })
            
            Picker("", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .onSubmit {
            withAnimation {
                guard let category = selectedCategory else {
                    print("Please select a category")
                    return
                }
                viewModel.createTodo(content: self.textFieldText, completed: false, categoryId: category.id)
                textFieldText.removeAll()
                selectedCategory = nil
            }
        }
    }
    
    struct TodoRowView: View {
        let todo: Todo
        @Binding var editMode: EditMode
        @ObservedObject var viewModel: CategoriesViewModel
        @Binding var textUpdate: [String: String]
        
        @State private var localText: String
        
        init(todo: Todo, editMode: Binding<EditMode>, viewModel: CategoriesViewModel, textUpdate: Binding<[String: String]>) {
            self.todo = todo
            self._editMode = editMode
            self.viewModel = viewModel
            self._textUpdate = textUpdate
            self._localText = State(initialValue: textUpdate.wrappedValue[todo.id] ?? todo.content)
        }
        
        var body: some View {
            HStack {
                if editMode != .active {
                    Button(action: {
                        viewModel.updateTodo(id: todo.id, content: todo.content, completed: !todo.completed, categoryId: todo.categoryId)
                    }, label: {
                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .padding(3)
                            .contentShape(.rect)
                            .foregroundStyle(todo.completed ? .gray : .accentColor)
                            .contentTransition(.symbolEffect(.replace))
                    })
                    
                    Text(todo.content)
                        .strikethrough(todo.completed)
                        .foregroundStyle(todo.completed ? .gray : .primary)
                } else {
                    TextField(text: $localText) {
                        Text(todo.content)
                    }
                    
                    .onChange(of: localText) { _,newValue in
                        textUpdate[todo.id] = newValue
                    }
                    .onSubmit {
                        viewModel.updateTodo(id: todo.id, content: localText, completed: todo.completed, categoryId: todo.categoryId)
                    }
                }
            }
        }
    }
}

#Preview {
    TodoView()
}
