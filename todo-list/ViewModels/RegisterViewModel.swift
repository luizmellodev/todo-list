//
//  RegisterViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//


import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    @Published var state: LoginViewState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    
    func register(username: String, password: String, name: String) {
        let parameters = [
            "username": username,
            "password": password,
            "name": name,
            "disaled": "false"
        ]
        
        networkManager.sendRequest("/register", method: "POST", parameters: parameters, authentication: nil, token: nil)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.state = .loggedIn
                case .failure(let error):
                    self.state = .error("Registration failed: \(error.localizedDescription)")
                }
            } receiveValue: { (response: UserResponse) in
                print("User created: \(response.username)")
                self.state = .loggedIn // Reset state or navigate to login
            }
            .store(in: &cancellables)
    }
}
