//
//  RegisterViewModelTests.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//


import XCTest
import Combine
@testable import todo_list

final class RegisterViewModelTests: XCTestCase {
    var viewModel: RegisterViewModel!
    var mockService: MockRegisterService!

    override func setUp() {
        super.setUp()
        mockService = MockRegisterService()
        viewModel = RegisterViewModel(registerService: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testRegisterSuccess() {
        let expectation = XCTestExpectation(description: "Register successfully")

        viewModel.register(username: "newuser", password: "password", name: "Test User")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.registerCalled, "register() should be called")
            XCTAssertEqual(self.viewModel.state, .loggedIn, "State should be loggedIn on success")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testRegisterFailure() {
        mockService.shouldFail = true
        let expectation = XCTestExpectation(description: "Register fails")

        viewModel.register(username: "newuser", password: "password", name: "Test User")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.registerCalled, "register() should be called")
            XCTAssertNotEqual(self.viewModel.state, .loggedIn, "State should not be loggedIn on failure")
            if case .error(let message) = self.viewModel.state {
                XCTAssertTrue(message.contains("Registration failed"), "Error message should indicate failure")
            } else {
                XCTFail("State should be in error mode")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
