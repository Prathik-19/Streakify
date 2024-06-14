//
//  LoginViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
import SwiftUI
@testable import Streakify

class LoginViewTests: XCTestCase {

    class LoginViewModel: ObservableObject {
        @Published var username: String = ""
        @Published var password: String = ""
        @Published var showLoginError: Bool = false

        func login(completion: @escaping (Bool) -> Void) {
            UserManager.shared.loginUser(username: username, password: password) { success, _ in
                DispatchQueue.main.async {
                    self.showLoginError = !success
                    completion(success)
                }
            }
        }
    }

    override func setUp() {
        super.setUp()
        UserManager.shared.clearUsers()
    }

    func testLoginSuccess() {
        // Given
        let viewModel = LoginViewModel()
        viewModel.username = "johndoe"
        viewModel.password = "Pass1234"
        
        // Create a user for testing
        let expectation = self.expectation(description: "User registration")
        UserManager.shared.createUser(name: "John Doe", username: viewModel.username, email: "john.doe@example.com", password: viewModel.password) { success in
            XCTAssertTrue(success, "User should be created successfully")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // When
        let loginExpectation = self.expectation(description: "User login")
        viewModel.login { success in
            XCTAssertTrue(success, "User should be able to log in with correct credentials.")
            loginExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLoginFailure() {
        // Given
        let viewModel = LoginViewModel()
        viewModel.username = "johndoe"
        viewModel.password = "WrongPass"
        
        // When
        let loginExpectation = self.expectation(description: "User login")
        viewModel.login { success in
            XCTAssertFalse(success, "User should not be able to log in with incorrect credentials.")
            loginExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
