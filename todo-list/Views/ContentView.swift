//
//  ContentView.swift
//  todo-list
//
//  Created by Luiz Mello on 03/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @AppStorage("access_token") private var token: String = ""
    @State var isLoggedIn: Bool = false

    var body: some View {
        NavigationView {
            if loginViewModel.isLoggedIn == true {
                TodoView(token: token)
            } else {
                LoginView()
            }
        }
        .onAppear {
            if let savedToken = getToken() {
                loginViewModel.verifyToken(token: savedToken)
            }
        }
    }

    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
