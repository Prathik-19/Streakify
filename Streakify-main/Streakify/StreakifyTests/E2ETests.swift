//
//  E2ETests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

//
//  E2ETests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
@testable import Streakify

class E2ETests: XCTestCase {

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

    class AddHabitViewModel: ObservableObject {
        @Published var habitName: String = ""
        @Published var habitDescription: String = ""
        @Published var habitDuration: String = ""
        @Published var startDate: Date = Date()
        @Published var notificationFrequency: String = "None"
        @Published var enableNotifications: Bool = false

        func addHabit(to habits: inout [Habit], for user: Database) -> Bool {
            guard let totalDays = Int(habitDuration), !habitName.isEmpty else {
                return false
            }
            
            let newHabit = Habit(
                name: habitName,
                description: habitDescription,
                streakCount: 0,
                isCompleted: false,
                totalDuration: totalDays,
                completionDates: [],
                notificationFrequency: enableNotifications ? notificationFrequency : "None",
                notificationTime: enableNotifications ? Date() : nil,
                notificationDays: []
            )
            
            habits.append(newHabit)
            UserManager.shared.addHabit(for: user, habit: newHabit) // Save the habit to the user
            return true
        }
    }

    class EditHabitViewModel: ObservableObject {
        @Published var habitName: String
        @Published var habitDescription: String
        @Published var habitDuration: String

        init(habit: Habit) {
            self.habitName = habit.name
            self.habitDescription = habit.description
            self.habitDuration = String(habit.totalDuration)
        }

        func saveChanges(to habits: inout [Habit], habit: Habit) -> Bool {
            guard let totalDays = Int(habitDuration), !habitName.isEmpty else {
                return false
            }
            
            if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                habits[index].name = habitName
                habits[index].description = habitDescription
                habits[index].totalDuration = totalDays
                return true
            }
            return false
        }
    }

    class DeleteHabitViewModel: ObservableObject {
        func deleteHabit(from habits: inout [Habit], habitID: UUID) -> Bool {
            if let index = habits.firstIndex(where: { $0.id == habitID }) {
                habits.remove(at: index)
                return true
            }
            return false
        }
    }

    override func setUp() {
        super.setUp()
        UserManager.shared.clearUsers()
    }

    func testFullEndToEndFlow() {
        // Sign Up
        let signUpViewModel = SignUpViewModel()
        signUpViewModel.name = "John Doe"
        signUpViewModel.username = "johndoe"
        signUpViewModel.email = "john.doe@example.com"
        signUpViewModel.password = "Pass1234"
        signUpViewModel.confirmPassword = "Pass1234"
        
        let signUpExpectation = self.expectation(description: "User sign up")
        signUpViewModel.signUp { success in
            XCTAssertTrue(success, "User should be able to sign up with valid details.")
            signUpExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // Log In
        let loginViewModel = LoginViewModel()
        loginViewModel.username = "johndoe"
        loginViewModel.password = "Pass1234"
        
        let loginExpectation = self.expectation(description: "User login")
        loginViewModel.login { success in
            XCTAssertTrue(success, "User should be able to log in with correct credentials.")
            loginExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // Add Habit
        var habits = [Habit]()
        let addHabitViewModel = AddHabitViewModel()
        addHabitViewModel.habitName = "Exercise"
        addHabitViewModel.habitDescription = "Daily exercise"
        addHabitViewModel.habitDuration = "30"
        
        let user = UserManager.shared.getUserByUsername("johndoe")!
        let addHabitSuccess = addHabitViewModel.addHabit(to: &habits, for: user)
        XCTAssertTrue(addHabitSuccess, "Habit should be added successfully.")
        XCTAssertEqual(habits.count, 1, "Habits count should be 1.")
        XCTAssertEqual(habits[0].name, "Exercise", "Habit name should be 'Exercise'.")
        
        // Edit Habit
        let editHabitViewModel = EditHabitViewModel(habit: habits[0])
        editHabitViewModel.habitName = "Yoga"
        editHabitViewModel.habitDescription = "Daily yoga practice"
        editHabitViewModel.habitDuration = "60"
        
        let editHabitSuccess = editHabitViewModel.saveChanges(to: &habits, habit: habits[0])
        XCTAssertTrue(editHabitSuccess, "Habit should be edited successfully.")
        XCTAssertEqual(habits[0].name, "Yoga", "Habit name should be 'Yoga'.")
        XCTAssertEqual(habits[0].description, "Daily yoga practice", "Habit description should be 'Daily yoga practice'.")
        XCTAssertEqual(habits[0].totalDuration, 60, "Habit duration should be 60.")
        
        // Delete Habit
        let deleteHabitViewModel = DeleteHabitViewModel()
        let deleteHabitSuccess = deleteHabitViewModel.deleteHabit(from: &habits, habitID: habits[0].id)
        XCTAssertTrue(deleteHabitSuccess, "Habit should be deleted successfully.")
        XCTAssertEqual(habits.count, 0, "Habits count should be 0.")
        
        // Sign Out
        UserManager.shared.logoutUser()
        
        // Log Back In
        loginViewModel.username = "johndoe"
        loginViewModel.password = "Pass1234"
        
        let reLoginExpectation = self.expectation(description: "User re-login")
        loginViewModel.login { success in
            XCTAssertTrue(success, "User should be able to log in with correct credentials after signing out.")
            reLoginExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // Verify No Habits Exist
        XCTAssertEqual(habits.count, 0, "Habits count should be 0 after logging back in.")
        
        // Add Another Habit
        addHabitViewModel.habitName = "Reading"
        addHabitViewModel.habitDescription = "Daily reading"
        addHabitViewModel.habitDuration = "15"
        
        let addHabitSuccess2 = addHabitViewModel.addHabit(to: &habits, for: user)
        XCTAssertTrue(addHabitSuccess2, "Habit should be added successfully.")
        XCTAssertEqual(habits.count, 1, "Habits count should be 1.")
        XCTAssertEqual(habits[0].name, "Reading", "Habit name should be 'Reading'.")
        
        // Sign Out
        UserManager.shared.logoutUser()
        
        // Log Back In
        loginViewModel.username = "johndoe"
        loginViewModel.password = "Pass1234"
        
        let finalLoginExpectation = self.expectation(description: "User final re-login")
        loginViewModel.login { success in
            XCTAssertTrue(success, "User should be able to log in with correct credentials after signing out.")
            finalLoginExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        // Verify Habit Exists
        XCTAssertTrue(habits.contains { $0.name == "Reading" }, "Habit 'Reading' should exist after logging back in.")
    }
}
