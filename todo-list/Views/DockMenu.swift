import SwiftUI

struct DockMenu: View {
    @Binding var editMode: EditMode
    @Binding var showingNewTodo: Bool
    @Binding var isGridView: Bool
    let onDelete: () -> Void
    
    @State private var isExpanded = false
    @State private var hoveredItem: DockItem?
    @State private var lastScrollPosition: CGFloat = 0
    @State private var isMenuVisible = true
    @State private var menuOffset: CGFloat = 0
    
    enum DockItem: String, CaseIterable {
        case add = "plus.circle"
        case view = "square.grid.2x2"
        case edit = "pencil.circle"
        case delete = "trash.circle"
        case cancel = "xmark.circle"
        
        var title: String {
            switch self {
            case .add: return "New Todo"
            case .view: return "Change View"
            case .edit: return "Edit Mode"
            case .delete: return "Delete"
            case .cancel: return "Cancel"
            }
        }
        
        var color: Color {
            switch self {
            case .add: return .blue
            case .view: return .purple
            case .edit: return .orange
            case .delete: return .red
            case .cancel: return .gray
            }
        }
    }
    
    private var visibleItems: [DockItem] {
        if editMode == .active {
            return [.delete, .cancel]
        } else {
            return [.add, .view, .edit]
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                HStack(spacing: 15) {
                    ForEach(visibleItems, id: \.self) { item in
                        if editMode == .inactive || item == .delete || item == .cancel {
                            Button(action: { handleAction(item) }) {
                                VStack(spacing: 2) {
                                    Image(systemName: item.rawValue)
                                        .font(.system(size: 20))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(item.color)
                                    
                                    if hoveredItem == item {
                                        Text(item.title)
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.ultraThinMaterial)
                                            .cornerRadius(6)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .frame(width: 40, height: hoveredItem == item ? 55 : 40)
                            }
                            .buttonStyle(.plain)
                            .onHover { isHovered in
                                withAnimation(.spring(response: 0.3)) {
                                    hoveredItem = isHovered ? item : nil
                                }
                            }
                            .scaleEffect(hoveredItem == item ? 1.1 : 1.0)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 8)
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
                .offset(y: menuOffset)
                .animation(.spring(response: 0.3), value: menuOffset)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: editMode)
    }
    
    
    private func handleAction(_ item: DockItem) {
        withAnimation(.spring()) {
            switch item {
            case .add:
                showingNewTodo = true
            case .view:
                isGridView.toggle()
            case .edit:
                editMode = .active
            case .delete:
                onDelete()
            case .cancel:
                editMode = .inactive
            }
        }
    }
}
