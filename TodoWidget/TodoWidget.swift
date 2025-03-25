//
//  TodoWidget.swift
//  TodoWidget
//
//  Created by Luiz Mello on 23/12/24.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    
    let data = DataService()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todos: fetchTodos(for: context.family))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todos: fetchTodos(for: context.family))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let entry = SimpleEntry(date: Date(), todos: fetchTodos(for: context.family))
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    // Função para determinar quantos todos exibir com base no tamanho do widget
    private func fetchTodos(for family: WidgetFamily) -> [Todo] {
        let todos = data.fetchTodos()
        
        switch family {
        case .systemSmall, .systemMedium:
            return Array(todos.prefix(4))
        case .systemLarge, .systemExtraLarge:
            return Array(todos.prefix(7))
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return Array(todos.prefix(1))
        @unknown default:
            return todos
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todos: [Todo]
}

struct TodoWidgetEntryView: View {
    var entry: Provider.Entry
    let data = DataService()
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.todos, id: \.id) { todo in
                HStack(spacing: 5) {
                    Button(intent: MarkAsDoneIntent(todoId: todo.id)) {
                        Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                            .contentShape(Rectangle())
                            .foregroundStyle(todo.completed ? .gray : .accentColor)
                    }
                    
                    Text(todo.content)
                        .strikethrough(todo.completed)
                        .foregroundStyle(todo.completed ? .gray : Color(UIColor.label))
                        .font(.caption)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct TodoWidget: Widget {
    let kind: String = "TodoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Todo Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    TodoWidget()
} timeline: {
    SimpleEntry(date: Date(), todos: [
        Todo(id: "1", username: "", content: "Buy apples", completed: true, createdAt: Date().ISO8601Format()),
        Todo(id: "2", username: "", content: "Buy apples", completed: false, createdAt: Date().ISO8601Format()),
        Todo(id: "3", username: "", content: "Buy apples", completed: false, createdAt: Date().ISO8601Format()),

    ])
}

#Preview(as: .systemMedium) {
    TodoWidget()
} timeline: {
    SimpleEntry(date: Date(), todos: [
        Todo(id: "1", username: "", content: "Buy apples", completed: true, createdAt: Date().ISO8601Format()),
        Todo(id: "2", username: "", content: "Buy apples", completed: false, createdAt: Date().ISO8601Format()),
        Todo(id: "3", username: "", content: "Buy apples", completed: false, createdAt: Date().ISO8601Format()),
    ])
}

