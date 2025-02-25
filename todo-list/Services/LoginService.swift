//
//  LoginServiceProtocol.swift
//  todo-list
//
//  Created by Luiz Mello on 25/02/25.
//

import Foundation
import Combine

protocol LoginServiceProtocol {
    func login(username: String, password: String) -> AnyPublisher<TokenResponse, NetworkError>
    func verifyToken(token: String) -> AnyPublisher<Bool, NetworkError>
}

class LoginService: LoginServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func login(username: String, password: String) -> AnyPublisher<TokenResponse, NetworkError> {
        let parameters = "username=\(username)&password=\(password)"
        
        return networkManager.sendRequest("/token", method: "POST", parameters: nil, authentication: parameters, token: nil, body: nil)
            .eraseToAnyPublisher()
    }
    
    func verifyToken(token: String) -> AnyPublisher<Bool, NetworkError> {
        return networkManager.sendRequest("/mytoken", method: "GET", parameters: nil, authentication: nil, token: token, body: nil)
            .map { (response: Bool) in response }
            .catch { _ in Just(false).setFailureType(to: NetworkError.self) }
            .eraseToAnyPublisher()
    }
}
