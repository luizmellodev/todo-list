import SwiftUI

struct TodoView: View {
    @State var textFieldText: String = ""
    @State var newTodoClicked: Bool = false
    @State private var selectedCategory: Category?
    
    @StateObject private var viewModel = CategoriesViewModel()
    
    @State private var newTodoClicked: Bool = false
    @State private var textFieldText: String = ""
    @State private var selectedCategory: Category?
    @State private var editMode: EditMode = .inactive
    @State private var textFieldUpdates: [String: String] = [:]
    @State private var hideCompleted = false
    @State private var isCategoryEmpty = false

    let token: String
    
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
    
    @ViewBuilder
    private var addTodoView: some View {
        HStack {
            TextField("Add new todo item", text: $textFieldText)
            
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
            viewModel.createTodo(content: textFieldText, completed: false, categoryId: category.id, token: token)
            textFieldText = ""
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
    
    var token: String
    
    init(todo: Todo, editMode: Binding<EditMode>, viewModel: CategoriesViewModel, textUpdate: Binding<[String: String]>, token: String) {
        self.todo = todo
        self._editMode = editMode
        self.viewModel = viewModel
        self._textUpdate = textUpdate
        self._localText = State(initialValue: textUpdate.wrappedValue[todo.id] ?? todo.content)
        self.token = token
    }
    
    var body: some View {
        HStack {
            if editMode == .inactive {
                Button(action: {
                    withAnimation {
                        viewModel.updateTodo(id: todo.id, content: todo.content, username: todo.username, completed: !todo.completed, categoryId: todo.categoryId, token: token)
                    }
                }) {
                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .padding(3)
                        .contentShape(Rectangle())
                        .foregroundStyle(todo.completed ? .gray : .accentColor)
                }
                
                Text(todo.content)
                    .strikethrough(todo.completed)
                    .foregroundStyle(todo.completed ? .gray : .primary)
            } else {
                TextField(todo.content, text: $localText)
                    .onChange(of: localText) { _, newValue in
                        textUpdate[todo.id] = newValue
                    }
                    .onSubmit {
                        viewModel.updateTodo(id: todo.id, content: localText, username: "", completed: todo.completed, categoryId: todo.categoryId, token: token)
                    }
            }
        }
    }
}
