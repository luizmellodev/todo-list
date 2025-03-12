//
//  OnboardingFinishedView.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import SwiftUI

struct OnboardingFinishedView: View {
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            Text("All Set!")
                .font(.largeTitle)
            Text("You've created your first todo and category. Let's get organized!")
                .padding()
            Button("Start Using TodoApp") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
