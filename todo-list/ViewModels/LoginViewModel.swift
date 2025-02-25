//
//  LoginViewModel.swift
//  todo-list
//
//  Created by Luiz Mello on 28/11/24.
//

import Foundation
import Combine

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
}

class LoginViewModel: ObservableObject {
    
    @Published var state: DefaultViewState = .started
    @Published var token: TokenResponse?
    
    private var cancellables = Set<AnyCancellable>()
    private let loginService: LoginServiceProtocol
    
    init(loginService: LoginServiceProtocol = LoginService()) {
        self.loginService = loginService
    }
    
    func login(username: String, password: String) {
        self.state = .loading
        
        loginService.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { token in
                self.saveToken(token.access_token)
                self.token = token
                self.state = .loggedIn
            }
            .store(in: &cancellables)
    }
    
    func verifyToken(token: String) {
        loginService.verifyToken(token: token)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { isValid in
                self.state = isValid ? .loggedIn : .requestFailed
            }
            .store(in: &cancellables)
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
}

