import SwiftUI

struct CategoryCell: View {
    let content: () -> AnyView
    let action: () -> Void
 
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> some View) {
        self.action = action
        self.content = { AnyView(content()) }
    }
 
    var body: some View {
        Button(action: action) {
            content()
                .shadow(color: .black.opacity(0.1), radius: 8)
                .overlay {
                    // Add glass effect
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .opacity(0.1)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .buttonStyle(CategoryButtonStyle())
    }
}

// Add custom button style for better interaction feedback
struct CategoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
