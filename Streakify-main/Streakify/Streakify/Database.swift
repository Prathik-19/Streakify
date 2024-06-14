import Foundation

class Database: Identifiable, Codable {
    var id: String
    var name: String
    var username: String
    var email: String
    var password: String
    var habits: [Habit]
    
    init(name: String, username: String, email: String, password: String) {
        self.id = UUID().uuidString
        self.name = name
        self.username = username
        self.email = email
        self.password = password
        self.habits = []
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func removeHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
    }
}
