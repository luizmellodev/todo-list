//
//  EmptyStateView.swift
//  todo-list
//
//  Created by Luiz Mello on 07/02/25.
//


import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image(systemName: "tray.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            Text("No todos yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
}
