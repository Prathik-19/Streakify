import Foundation
import CryptoKit

class UserManager {
    static let shared = UserManager()
    
    private var users: [Database] = []
    private var loggedInUser: Database? = nil  // Current logged-in user
    
    private init() {
        loadUsers()
    }
    
    func createUser(name: String, username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        if let _ = getUserByEmail(email) {
            completion(false)
            return
        }
        
        let hashedPassword = hashPassword(password)
        let newUser = Database(name: name, username: username, email: email, password: hashedPassword)
        
        if saveUser(newUser) {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func loginUser(username: String, password: String, completion: @escaping (Bool, Database?) -> Void) {
        guard let user = getUserByUsername(username) else {
            completion(false, nil)
            return
        }
        
        if verifyPassword(password, hashedPassword: user.password) {
            loggedInUser = user
            completion(true, user)
        } else {
            completion(false, nil)
        }
    }
    
    func logoutUser() {
        loggedInUser = nil
    }
    
    func addHabit(for user: Database, habit: Habit) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            if let habitIndex = users[index].habits.firstIndex(where: { $0.id == habit.id }) {
                users[index].habits[habitIndex] = habit
            } else {
                users[index].habits.append(habit)
            }
            saveUsers()
        }
    }
    
    func removeHabit(for user: Database, habit: Habit) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].removeHabit(habit)
            saveUsers()
        }
    }
    
    func getUserByEmail(_ email: String) -> Database? {
        return users.first(where: { $0.email == email })
    }

    func getUserByUsername(_ username: String) -> Database? {
        return users.first(where: { $0.username == username })
    }
    
    func clearUsers() {
        users.removeAll()
        UserDefaults.standard.removeObject(forKey: "users")
    }
    
    private func saveUser(_ user: Database) -> Bool {
        users.append(user)
        saveUsers()
        return true
    }
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "users")
        }
    }
    
    private func loadUsers() {
        if let savedUsers = UserDefaults.standard.data(forKey: "users") {
            if let decodedUsers = try? JSONDecoder().decode([Database].self, from: savedUsers) {
                users = decodedUsers
            }
        }
    }
    
    
    func updateUserPassword(username: String, newPassword: String) {
        if let index = users.firstIndex(where: { $0.username == username }) {
            let hashedPassword = hashPassword(newPassword)
            users[index].password = hashedPassword
            saveUsers()
        }
    }
        
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func verifyPassword(_ password: String, hashedPassword: String) -> Bool {
        let hashedInputPassword = hashPassword(password)
        return hashedInputPassword == hashedPassword
    }
}
