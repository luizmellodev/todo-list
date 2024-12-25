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
    
    @Published var isLoggedIn: Bool?
    @Published var token: TokenResponse?
    @Published var state: LoginViewState = .idle
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    
    func login(username: String, password: String) {
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
                self.state = . loggedIn
            }
            .store(in: &cancellables)
    }
    
    func verifyToken(token: String) {
        networkManager.sendRequest("/mytoken", method: "GET", parameters: nil, authentication: nil, token: token)
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Bool> in
                print("Error fetching verifytoken: \(error)")
                return Just(false)
            }
            .map {$0}
            .assign(to: &$isLoggedIn)
        print("Token verificado: \(self.isLoggedIn ?? false)")
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
    }
    
    internal func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
}
