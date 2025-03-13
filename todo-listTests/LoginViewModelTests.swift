//
//  LoginViewModelTests.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import XCTest
import Combine
@testable import todo_list

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockService: MockLoginService!
    
    override func setUp() {
        super.setUp()
        mockService = MockLoginService()
        viewModel = LoginViewModel(loginService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testLoginSuccess() {
        let expectation = XCTestExpectation(description: "Login successfully")
        
        viewModel.login(username: "user", password: "password")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.loginCalled, "login() should be called")
            XCTAssertEqual(self.viewModel.token?.access_token, "mock_token", "Token should be received")
            XCTAssertEqual(self.viewModel.state, .loggedIn, "State should be loggedIn")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testVerifyTokenSuccess() {
        let expectation = XCTestExpectation(description: "Verify token successfully")
        
        viewModel.verifyToken(token: "valid_token")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.verifyTokenCalled, "verifyToken() should be called")
            XCTAssertEqual(self.viewModel.state, .loggedIn, "State should be loggedIn")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
