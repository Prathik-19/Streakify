//
//  DeleteHabitViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

//
//  DeleteHabitViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
@testable import Streakify

class DeleteHabitViewTests: XCTestCase {

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

    func testDeleteHabitSuccess() {
        // Given
        var habits = [Habit]()
        let habit = Habit(name: "Exercise", description: "Daily exercise", totalDuration: 30)
        habits.append(habit)
        
        let viewModel = DeleteHabitViewModel()
        
        // When
        let success = viewModel.deleteHabit(from: &habits, habitID: habit.id)
        
        // Then
        XCTAssertTrue(success, "Habit should be deleted successfully.")
        XCTAssertEqual(habits.count, 0, "Habits count should be 0.")
    }

    func testDeleteHabitFailure() {
        // Given
        var habits = [Habit]()
        let habit = Habit(name: "Exercise", description: "Daily exercise", totalDuration: 30)
        habits.append(habit)
        
        let anotherHabit = Habit(name: "Reading", description: "Daily reading", totalDuration: 15)
        
        let viewModel = DeleteHabitViewModel()
        
        // When
        let success = viewModel.deleteHabit(from: &habits, habitID: anotherHabit.id)
        
        // Then
        XCTAssertFalse(success, "Habit should not be deleted if it does not exist in the list.")
        XCTAssertEqual(habits.count, 1, "Habits count should remain 1.")
    }
}
