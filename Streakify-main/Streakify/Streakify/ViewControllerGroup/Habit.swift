import Foundation
import SwiftUI

struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var streakCount: Int
    var isCompleted: Bool
    var totalDuration: Int
    var completionDates: [Date]
    var notificationFrequency: String
    var notificationTime: Date?
    var notificationDays: [String]
    
    init(name: String, description: String = "Default description", streakCount: Int = 0, isCompleted: Bool = false, totalDuration: Int, completionDates: [Date] = [], notificationFrequency: String = "None", notificationTime: Date? = nil, notificationDays: [String] = []) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.streakCount = streakCount
        self.isCompleted = isCompleted
        self.totalDuration = totalDuration
        self.completionDates = completionDates
        self.notificationFrequency = notificationFrequency
        self.notificationTime = notificationTime
        self.notificationDays = notificationDays
    }

    var progress: CGFloat {
        return CGFloat(streakCount) / CGFloat(totalDuration)
    }

    var progressPercentage: Int {
        return min(Int((progress * 100).rounded()), 100)
    }
}

extension Habit {
    var startDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())  // Dummy date for illustration
    }

    var endDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date().addingTimeInterval(Double(totalDuration * 86400)))  // Dummy end date for illustration
    }

    var formattedCompletionDates: [String] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return completionDates.map { formatter.string(from: $0) }
    }
}
