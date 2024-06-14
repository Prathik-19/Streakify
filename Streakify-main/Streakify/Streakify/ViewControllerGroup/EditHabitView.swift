import SwiftUI

struct EditHabitView: View {
    @Environment(\.presentationMode) var presentationMode
    var habit: Habit
    @ObservedObject var database: Database
    
    @State private var habitName: String
    @State private var habitDescription: String
    @State private var habitDuration: Int
    
    init(habit: Habit, database: Database) {
        self.habit = habit
        self._database = ObservedObject(wrappedValue: database)
        self._habitName = State(initialValue: habit.name)
        self._habitDescription = State(initialValue: habit.description)
        self._habitDuration = State(initialValue: habit.totalDuration)
    }

    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255)
    let darkTealColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255)

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    TextField("Habit Name", text: $habitName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)

                    TextField("Description", text: $habitDescription)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)

                    TextField("Total Days", value: $habitDuration, formatter: NumberFormatter())
                        .padding(10)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5)
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    Button("Save Changes") {
                        if habitDuration > 0 && !habitName.isEmpty {
                            if let index = database.habits.firstIndex(where: { $0.id == habit.id }) {
                                database.habits[index].name = habitName
                                database.habits[index].description = habitDescription
                                database.habits[index].totalDuration = habitDuration
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(habitName.isEmpty || habitDuration == 0 ? Color.gray : darkTealColor)
                    .foregroundColor(.white)
                    .cornerRadius(5.0)
                    .disabled(habitName.isEmpty || habitDuration == 0)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Habit")
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

struct EditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitView(habit: Habit(name: "Sample Habit", description: "Sample Description", totalDuration: 30), database: Database(name: "Test User", username: "testuser", email: "test@example.com", password: "password"))
    }
}
