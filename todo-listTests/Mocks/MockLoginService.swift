//
//  MockLoginService.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import XCTest
import Combine
@testable import todo_list

class MockLoginService: LoginServiceProtocol {
    var shouldFail = false
    var loginCalled = false
    var verifyTokenCalled = false
    
    func login(username: String, password: String) -> AnyPublisher<TokenResponse, NetworkError> {
        loginCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        let tokenResponse = TokenResponse(access_token: "mock_token", token_type: "Bearer")
        return Just(tokenResponse).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
    
    func verifyToken(token: String) -> AnyPublisher<Bool, NetworkError> {
        verifyTokenCalled = true
        if shouldFail {
            return Fail(error: .badServerResponse).eraseToAnyPublisher()
        }
        return Just(true).setFailureType(to: NetworkError.self).eraseToAnyPublisher()
    }
}
