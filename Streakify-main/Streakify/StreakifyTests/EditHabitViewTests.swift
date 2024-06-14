//
//  EditHabitViewTests.swift
//  StreakifyTests
//
//  Created by Srikar Rani on 6/12/24.
//

import XCTest
@testable import Streakify

class EditHabitViewTests: XCTestCase {

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

    override func setUp() {
        super.setUp()
        UserManager.shared.clearUsers()
    }

    func testEditHabitSuccess() {
        // Given
        var habits = [Habit]()
        let habit = Habit(name: "Exercise", description: "Daily exercise", totalDuration: 30)
        habits.append(habit)
        
        let viewModel = EditHabitViewModel(habit: habit)
        viewModel.habitName = "Yoga"
        viewModel.habitDescription = "Daily yoga practice"
        viewModel.habitDuration = "60"
        
        // When
        let success = viewModel.saveChanges(to: &habits, habit: habit)
        
        // Then
        XCTAssertTrue(success, "Habit should be edited successfully.")
        XCTAssertEqual(habits[0].name, "Yoga", "Habit name should be 'Yoga'.")
        XCTAssertEqual(habits[0].description, "Daily yoga practice", "Habit description should be 'Daily yoga practice'.")
        XCTAssertEqual(habits[0].totalDuration, 60, "Habit duration should be 60.")
    }

    func testEditHabitFailure() {
        // Given
        var habits = [Habit]()
        let habit = Habit(name: "Exercise", description: "Daily exercise", totalDuration: 30)
        habits.append(habit)
        
        let viewModel = EditHabitViewModel(habit: habit)
        viewModel.habitName = ""
        viewModel.habitDescription = "Daily yoga practice"
        viewModel.habitDuration = "60"
        
        // When
        let success = viewModel.saveChanges(to: &habits, habit: habit)
        
        // Then
        XCTAssertFalse(success, "Habit should not be edited with empty name.")
        XCTAssertEqual(habits[0].name, "Exercise", "Habit name should remain 'Exercise'.")
    }
}
