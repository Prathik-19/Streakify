import SwiftUI

struct AddHabitView: View {
    @ObservedObject var database: Database
    @State private var habitName = ""
    @State private var habitDescription = ""
    @State private var totalDuration = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255) // Background color
    let darkTealColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255) // Button color
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Habit Name")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        TextField("Enter habit name", text: $habitName)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10.0)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Description")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        TextField("Enter habit description", text: $habitDescription)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10.0)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Total Days")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        TextField("Enter number of days", value: $totalDuration, formatter: NumberFormatter())
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10.0)
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        if totalDuration > 0 && !habitName.isEmpty {
                            let newHabit = Habit(name: habitName, description: habitDescription, totalDuration: totalDuration)
                            database.addHabit(newHabit)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Add Habit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(habitName.isEmpty || totalDuration == 0 ? Color.gray : darkTealColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(habitName.isEmpty || totalDuration == 0)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add New Habit")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(database: Database(name: "Test User", username: "testuser", email: "test@example.com", password: "password"))
    }
}
