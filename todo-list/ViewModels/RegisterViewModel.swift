//
//  RegisterViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//


import Foundation
import Combine

class RegisterViewModel: ObservableObject {
    
    @Published var state: DefaultViewState = .started
    var onSuccessfulRegister: ((String, String) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    private let registerService: RegisterServiceProtocol

    
    init(registerService: RegisterServiceProtocol = RegisterService()) {
        self.registerService = registerService
    }
    
    func register(username: String, password: String, name: String) {
        
        registerService.register(username: username, password: password, name: name)
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
                self.state = .loggedIn
                self.onSuccessfulRegister?(username, password)
            }
            .store(in: &cancellables)
    }
}
