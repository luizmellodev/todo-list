//
//  RegisterServiceProtocol.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import Foundation
import Combine

protocol RegisterServiceProtocol {
    func register(username: String, password: String, name: String) -> AnyPublisher<UserResponse, NetworkError>
}

class RegisterService: RegisterServiceProtocol {
    private let networkManager: NetworkManagerProtocol

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    func register(username: String, password: String, name: String) -> AnyPublisher<UserResponse, NetworkError> {
        let parameters = [
            "username": username,
            "password": password,
            "name": name,
            "disabled": "false"
        ]

        return networkManager.sendRequest("/register", method: "POST", parameters: parameters, authentication: nil, token: nil, body: nil)
            .eraseToAnyPublisher()
    }
}
