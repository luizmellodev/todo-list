//
//  WelcomeView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct WelcomeView: View {
    let nextStep: () -> Void
    
    var body: some View {
        VStack {
            Text("Welcome to TodoApp!")
                .font(.largeTitle)
            Text("Let's get started by creating your first todo.")
                .padding()
            Button("Create Todo") {
                nextStep()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
