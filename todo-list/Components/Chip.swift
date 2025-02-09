//
//  Chip.swift
//  todo-list
//
//  Created by Luiz Mello on 05/02/25.
//

import SwiftUI

internal struct Chip: View {

    private var title: String
    private var isSelected: Bool
    private var background: Color
    private var action: () -> Void

    init(
        _ title: String,
        isSelected: Bool = false,
        background: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.background = background
        self.action = action
    }

    public var body: some View {
        Button(title, action: action)
            .buttonStyle(
                ChipStyle(
                    isSelected: isSelected,
                    background: background
                )
            )
    }

}

private struct ChipStyle: ButtonStyle {
    
    private var isSelected: Bool
    private var background: Color

    @State private var appearsSelected: Bool

    init(
        isSelected: Bool,
        background: Color
    ) {
        self.isSelected = isSelected
        self.background = background
        _appearsSelected = State(initialValue: isSelected)
    }

    @MainActor
    func makeBody(configuration: Self.Configuration) -> some View {

        let chipHeight: CGFloat = 30

        let chipShape = RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))

        HStack(spacing: 4) {

            configuration.label
                .font(.body)
                .lineLimit(1)
                .foregroundStyle(appearsSelected ? .white : .black)
                .padding()
        }
        .padding(.horizontal, 4)
        .frame(height: chipHeight)
        .clipShape(chipShape)
        .background {
            chipShape
                .foregroundStyle(appearsSelected ? background : .clear)
                .overlay {
                    chipShape
                        .strokeBorder(lineWidth: 1)
                        .foregroundStyle(appearsSelected ? .clear : .gray.opacity(0.2))
                }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .scaleEffect(withAnimation { isSelected ? 1.15 : 1 } )
        .onChange(of: isSelected) { _,newSelected in
            withAnimation(nil) {
                appearsSelected = shouldAppearSelected(
                    isSelected: newSelected,
                    isPressed: configuration.isPressed
                )
            }
        }
        .onChange(of: configuration.isPressed) { _,newPressed in
            withAnimation(nil) {
                appearsSelected = shouldAppearSelected(
                    isSelected: isSelected,
                    isPressed: newPressed
                )
            }
        }
    }

    private func shouldAppearSelected(isSelected: Bool, isPressed: Bool) -> Bool {
        isSelected || isPressed
    }

}

#Preview {
    Chip("Test", isSelected: false, background: .blue, action: {})
    Chip("Test", isSelected: true, background: .blue, action: {})
    Chip("Test", isSelected: false, background: .blue, action: {})
    Chip("Test", isSelected: false, background: .blue, action: {})
    Chip("Test", isSelected: false, background: .blue, action: {})

}
