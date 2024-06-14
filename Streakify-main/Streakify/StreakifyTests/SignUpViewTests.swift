//
//  SignUpViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
@testable import Streakify

class SignUpViewTests: XCTestCase {
    
    class SignUpViewModel: ObservableObject {
        @Published var name: String = ""
        @Published var username: String = ""
        @Published var email: String = ""
        @Published var password: String = ""
        @Published var confirmPassword: String = ""
        @Published var showSignUpError: Bool = false

        func signUp(completion: @escaping (Bool) -> Void) {
            if password != confirmPassword {
                self.showSignUpError = true
                completion(false)
                return
            }
            UserManager.shared.createUser(name: name, username: username, email: email, password: password) { success in
                DispatchQueue.main.async {
                    self.showSignUpError = !success
                    completion(success)
                }
            }
        }
    }

    override func setUp() {
        super.setUp()
        UserManager.shared.clearUsers()
    }

    func testSignUpSuccess() {
        let viewModel = SignUpViewModel()
        viewModel.name = "John Doe"
        viewModel.username = "johndoe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "Pass1234"
        viewModel.confirmPassword = "Pass1234"
        
        let expectation = self.expectation(description: "User sign up")
        viewModel.signUp { success in
            XCTAssertTrue(success, "User should be able to sign up with valid details.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSignUpFailureDueToPasswordMismatch() {
        let viewModel = SignUpViewModel()
        viewModel.name = "John Doe"
        viewModel.username = "johndoe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "Pass1234"
        viewModel.confirmPassword = "WrongPass"
        
        let expectation = self.expectation(description: "User sign up")
        viewModel.signUp { success in
            XCTAssertFalse(success, "User should not be able to sign up if passwords do not match.")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testSignUpFailureDueToExistingEmail() {
        let viewModel = SignUpViewModel()
        viewModel.name = "John Doe"
        viewModel.username = "johndoe"
        viewModel.email = "john.doe@example.com"
        viewModel.password = "Pass1234"
        viewModel.confirmPassword = "Pass1234"
        
        let firstExpectation = self.expectation(description: "First user sign up")
        viewModel.signUp { success in
            XCTAssertTrue(success, "First user should be able to sign up with valid details.")
            firstExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let secondExpectation = self.expectation(description: "Second user sign up")
        viewModel.signUp { success in
            XCTAssertFalse(success, "Second user should not be able to sign up with existing email.")
            secondExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
