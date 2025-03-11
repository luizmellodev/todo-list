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
    private let networkManager = NetworkManager.shared
    
    // Função de login
    func login(username: String, password: String) {
        self.state = .loading
        let parameters = "username=\(username)&password=\(password)"
        
        networkManager.sendRequest("/token", method: "POST", parameters: nil, authentication: parameters, token: nil)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.state = .error(error.localizedDescription)
                }
            } receiveValue: { (token: TokenResponse) in
                self.saveToken(token.access_token)
                self.token = token
                self.state = .loggedIn
            }
            .store(in: &cancellables)
    }
    
    // Função de verificação de token
    func verifyToken(token: String) {
        networkManager.sendRequest("/mytoken", method: "GET", parameters: nil, authentication: nil, token: token)
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Bool> in
                print("Error fetching verifytoken: \(error)")
                return Just(false)
            }
            .map { $0 ? .loggedIn : .requestFailed }
            .sink(receiveValue: { updatedState in
                self.state = updatedState
                print("Token verificado: \(self.state)")
            })
            .store(in: &cancellables)
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
}
