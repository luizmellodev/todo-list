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
        let userCreate = [
            "username": username,
            "name": name,
            "password": password
        ]
        
        let bodyData: Data?
        do {
            bodyData = try JSONSerialization.data(withJSONObject: userCreate)
        } catch {
            return Fail(error: .encodingError).eraseToAnyPublisher()
        }

        return networkManager.sendRequest(
            "/register",
            method: "POST",
            parameters: nil,
            authentication: nil,
            token: nil,
            body: bodyData
        )
        .eraseToAnyPublisher()
    }
}
