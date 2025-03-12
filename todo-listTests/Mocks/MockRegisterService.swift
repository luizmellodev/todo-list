//
//  MockRegisterService.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import Foundation
import Combine
@testable import todo_list

class MockRegisterService: RegisterServiceProtocol {
    var shouldFail = false
    var registerCalled = false

    func register(username: String, password: String, name: String) -> AnyPublisher<UserResponse, NetworkError> {
        registerCalled = true

        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }

        let userResponse = UserResponse(username: username, name: name, disabled: false)
        return Just(userResponse).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
}
