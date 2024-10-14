//
//  TodoView.swift
//  todo-list
//
//  Created by Luiz Mello on 25/09/24.
//
import SwiftUI

struct TodoView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    @State var newTodoClicked: Bool = false
    @State var textFieldText: String = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
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
                    .id(category.id)
                }
            }
            .navigationTitle("Todo List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: EditButton())
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    withAnimation {
                        self.newTodoClicked.toggle()
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
    
    struct TodoRowView: View {
        let todo: Todo
        @ObservedObject var viewModel: CategoriesViewModel
        
        var body: some View {
            HStack {
                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .padding(3)
                    .contentShape(.rect)
                    .foregroundStyle(todo.completed ? .gray : .accentColor)
                    .contentTransition(.symbolEffect(.replace))
                
                Text(todo.content)
                    .strikethrough(todo.completed)
                    .foregroundStyle(todo.completed ? .gray : .primary)
                Spacer()
            }
        }
    }
}

#Preview {
    TodoView()
}
