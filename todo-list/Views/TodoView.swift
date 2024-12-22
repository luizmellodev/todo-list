import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    @State private var newTodoClicked: Bool = false
    @State private var textFieldText: String = ""
    @State private var selectedCategory: Category?
    @State private var editMode: EditMode = .inactive
    @State private var textFieldUpdates: [String: String] = [:]
    
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
                    addTodoView
                }
                
                ForEach(viewModel.categories) { category in
                    Section(header: Text(category.name)) {
                        ForEach(category.todos) { todo in
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
            guard let category = selectedCategory else {
                print("Please select a category")
                return
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
                        viewModel.updateTodo(id: todo.id, content: todo.content, username: "", completed: !todo.completed, categoryId: todo.categoryId, token: token)
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
