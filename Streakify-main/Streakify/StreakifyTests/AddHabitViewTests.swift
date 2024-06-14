//
//  AddHabitViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

//
//  AddHabitViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
@testable import Streakify

class AddHabitViewTests: XCTestCase {

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

    override func setUp() {
        super.setUp()
        UserManager.shared.clearUsers()
    }

    func testAddHabitSuccess() {
        // Given
        let viewModel = AddHabitViewModel()
        viewModel.habitName = "Exercise"
        viewModel.habitDescription = "Daily exercise"
        viewModel.habitDuration = "30"
        
        var habits = [Habit]()
        let user = Database(name: "John Doe", username: "johndoe", email: "john.doe@example.com", password: "password")
        UserManager.shared.createUser(name: user.name, username: user.username, email: user.email, password: user.password) { _ in }
        
        // When
        let success = viewModel.addHabit(to: &habits, for: user)
        
        // Then
        XCTAssertTrue(success, "Habit should be added successfully.")
        XCTAssertEqual(habits.count, 1, "Habits count should be 1.")
        XCTAssertEqual(habits[0].name, "Exercise", "Habit name should be 'Exercise'.")
    }

    func testAddHabitFailure() {
        // Given
        let viewModel = AddHabitViewModel()
        viewModel.habitName = ""
        viewModel.habitDescription = "Daily exercise"
        viewModel.habitDuration = "30"
        
        var habits = [Habit]()
        let user = Database(name: "John Doe", username: "johndoe", email: "john.doe@example.com", password: "password")
        UserManager.shared.createUser(name: user.name, username: user.username, email: user.email, password: user.password) { _ in }
        
        // When
        let success = viewModel.addHabit(to: &habits, for: user)
        
        // Then
        XCTAssertFalse(success, "Habit should not be added with empty name.")
        XCTAssertEqual(habits.count, 0, "Habits count should be 0.")
    }
}
