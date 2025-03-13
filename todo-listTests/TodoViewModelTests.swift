//
//  TodoViewModelTests.swift
//  todo-list
//
//  Created by Luiz Mello on 11/03/25.
//

import XCTest
import Combine
@testable import todo_list

final class TodoViewModelTests: XCTestCase {
    var viewModel: TodoViewModel!
    var mockService: MockTodoService!
    
    override func setUp() {
        super.setUp()
        mockService = MockTodoService()
        viewModel = TodoViewModel(todoService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchCategoriesSuccess() {
        let expectation = XCTestExpectation(description: "Fetch categories successfully")
        
        viewModel.fetchCategories(token: "valid_token")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.fetchCategoriesCalled, "fetchCategories() should be called")
            XCTAssertEqual(self.viewModel.categories.count, 1, "There should be one category fetched")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchCategoriesFailure() {
        mockService.shouldFail = true
        let expectation = XCTestExpectation(description: "Fetch categories fails")
        
        viewModel.fetchCategories(token: "invalid_token")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.fetchCategoriesCalled, "fetchCategories() should be called")
            XCTAssertEqual(self.viewModel.categories.count, 0, "No categories should be fetched on failure")
            XCTAssertEqual(self.viewModel.state, .noConnection, "ViewModel should update state to noConnection on failure")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testCreateCategorySuccess() {
        let expectation = XCTestExpectation(description: "Create category successfully")
        
        viewModel.createCategory(name: "Personal", token: "valid_token")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.mockService.createCategoryCalled, "createCategory() should be called")
            XCTAssertEqual(self.viewModel.categories.count, 1, "Category should be added")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
}
