import SwiftUI

struct MainPageView: View {
    @State private var habits: [Habit] = []
    @State private var showingAddHabit = false
    @State private var showingSettings = false
    
    let username: String
    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255)
    let progressTrackColor = Color.white.opacity(0.3)
    let progressColor = Color.green

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    HStack {
                        Text("Hey \(username)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding([.top, .leading])

                        Spacer()

                        Button("Sign Out") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.red)
                        .cornerRadius(10)
                    }

                    List {
                        ForEach(habits) { habit in
                            HabitRow(habit: habit, habits: $habits, username: username)
                                .listRowBackground(backgroundColor)
                        }
                        .onDelete(perform: deleteHabits)
                    }
                    .listStyle(PlainListStyle())
                    .background(backgroundColor)

                    HStack {
                        Button(action: {
                            showingSettings.toggle()
                        }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Settings")
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .sheet(isPresented: $showingSettings) {
                            SettingsView()
                        }

                        Spacer()

                        Button(action: {
                            showingAddHabit.toggle()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("Add Habit")
                            }
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .sheet(isPresented: $showingAddHabit) {
                            if let currentUser = UserManager.shared.getUserByUsername(username) {
                                AddHabitView(habits: $habits, user: currentUser)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            loadHabits()
        }
    }

    func loadHabits() {
        if let currentUser = UserManager.shared.getUserByUsername(username) {
            habits = currentUser.habits
        }
    }

    func deleteHabits(at offsets: IndexSet) {
        if let currentUser = UserManager.shared.getUserByUsername(username) {
            for index in offsets {
                UserManager.shared.removeHabit(for: currentUser, habit: habits[index])
            }
            habits.remove(atOffsets: offsets)
        }
    }
}

struct HabitRow: View {
    var habit: Habit
    @Binding var habits: [Habit]
    var username: String

    @State private var showingDetail = false
    @State private var showingNotificationSettings = false

    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                    habits[index].isCompleted.toggle()
                    if habits[index].isCompleted {
                        habits[index].streakCount = habits[index].totalDuration
                        if !habits[index].completionDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
                            habits[index].completionDates.append(Date()) // Track completion date
                        }
                    } else {
                        habits[index].streakCount = 0  // Reset streak count
                        habits[index].completionDates.removeAll(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) // Remove today's completion date
                    }
                }
                if let currentUser = UserManager.shared.getUserByUsername(username) {
                    UserManager.shared.addHabit(for: currentUser, habit: habits.first { $0.id == habit.id }!)
                }
            }) {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }

            VStack(alignment: .leading) {
                Text(habit.name)
                    .foregroundColor(.white)
                    .strikethrough(habit.isCompleted, color: .white)

                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.3))
                        .frame(width: 140, height: 8)
                    Capsule().fill(Color.green)
                        .frame(width: CGFloat(habit.progress) * 140, height: 8)

                    Text(habit.isCompleted ? "Completed" : "\(Int(habit.progressPercentage))%")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.bold)
                        .position(x: 70, y: 4)
                }
                .frame(width: 140, height: 8)
                .cornerRadius(4)
            }
            .onTapGesture {
                showingDetail = true
            }
            .background(
                NavigationLink(
                    destination: HabitDetailView(habit: habit, habits: $habits, username: username),
                    isActive: $showingDetail,
                    label: { EmptyView() }
                )
                .hidden()
            )

            Spacer()

            Button(action: {
                if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                    if !habits[index].isCompleted && habits[index].streakCount < habits[index].totalDuration {
                        habits[index].streakCount += 1
                        if habits[index].streakCount == habits[index].totalDuration {
                            habits[index].isCompleted = true
                            if !habits[index].completionDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: Date()) }) {
                                habits[index].completionDates.append(Date()) // Track completion date
                            }
                        }
                    }
                }
                if let currentUser = UserManager.shared.getUserByUsername(username) {
                    UserManager.shared.addHabit(for: currentUser, habit: habits.first { $0.id == habit.id }!)
                }
            }) {
                ZStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(habit.isCompleted ? .gray : .orange)
                    Text("\(habit.streakCount)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                showingNotificationSettings = true
            }) {
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingNotificationSettings) {
                if let currentUser = UserManager.shared.getUserByUsername(username),
                   let habitIndex = currentUser.habits.firstIndex(where: { $0.id == habit.id }) {
                    NotificationSettingsView(habit: $habits[habitIndex])
                }
            }

            Button(action: {
                if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                    habits.remove(at: index)
                    if let currentUser = UserManager.shared.getUserByUsername(username) {
                        UserManager.shared.removeHabit(for: currentUser, habit: habit)
                    }
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .background(Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255))
        .cornerRadius(10)
    }
}

struct HabitDetailView: View {
    var habit: Habit
    @Binding var habits: [Habit]
    var username: String

    @State private var showingEditHabit = false
    @State private var showingHistory = false
    @State private var quote: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(habit.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Streak: \(habit.streakCount) / \(habit.totalDuration)")
                    .font(.title2)

                ProgressView(value: habit.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                    .padding(.vertical)

                Text("Start Date: \(habit.startDateFormatted)")
                    .font(.body)
                Text("End Date: \(habit.endDateFormatted)")
                    .font(.body)

                Text("Description")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(habit.description)
                    .font(.body)
                
                let quotes = [
                    "\"The only way to do great work is to love what you do.\" - Steve Jobs",
                    "\"Success is not the key to happiness. Happiness is the key to success. If you love what you are doing, you will be successful.\" - Albert Schweitzer",
                    "\"Don't watch the clock; do what it does. Keep going.\" - Sam Levenson",
                    "\"The future belongs to those who believe in the beauty of their dreams.\" - Eleanor Roosevelt",
                    "\"It does not matter how slowly you go as long as you do not stop.\" - Confucius",
                    "\"You are never too old to set another goal or to dream a new dream.\" - C.S. Lewis",
                    "\"The way to get started is to quit talking and begin doing.\" - Walt Disney",
                    "\"Believe you can and you're halfway there.\" - Theodore Roosevelt",
                    "\"The only limit to our realization of tomorrow is our doubts of today.\" - Franklin D. Roosevelt",
                    "\"The harder the conflict, the greater the triumph.\" - George Washington",
                    "\"Don't wait for opportunity. Create it.\" - Unknown",
                    "\"Success usually comes to those who are too busy to be looking for it.\" - Henry David Thoreau",
                    "\"Don’t be pushed around by the fears in your mind. Be led by the dreams in your heart.\" - Roy T. Bennett",
                    "\"Hardships often prepare ordinary people for an extraordinary destiny.\" - C.S. Lewis",
                    "\"Your time is limited, don't waste it living someone else's life.\" - Steve Jobs",
                    "\"Success is not in what you have, but who you are.\" - Bo Bennett",
                    "\"Start where you are. Use what you have. Do what you can.\" - Arthur Ashe",
                    "\"I find that the harder I work, the more luck I seem to have.\" - Thomas Jefferson",
                    "\"The best way to predict the future is to create it.\" - Peter Drucker",
                    "\"Dream big and dare to fail.\" - Norman Vaughan",
                    "\"Don't be afraid to give up the good to go for the great.\" - John D. Rockefeller",
                    "\"I am not a product of my circumstances. I am a product of my decisions.\" - Stephen Covey",
                    "\"Success is walking from failure to failure with no loss of enthusiasm.\" - Winston Churchill",
                    "\"The only place where success comes before work is in the dictionary.\" - Vidal Sassoon",
                    "\"Don’t let yesterday take up too much of today.\" - Will Rogers",
                    "\"You learn more from failure than from success. Don’t let it stop you. Failure builds character.\" - Unknown",
                    "\"The road to success and the road to failure are almost exactly the same.\" - Colin R. Davis",
                    "\"Don’t wish it were easier. Wish you were better.\" - Jim Rohn",
                    "\"It’s not whether you get knocked down, it’s whether you get up.\" - Vince Lombardi",
                    "\"If you are not willing to risk the usual, you will have to settle for the ordinary.\" - Jim Rohn",
                    "\"Go the extra mile. It's never crowded there.\" - Dr. Wayne D. Dyer",
                    "\"Keep your face always toward the sunshine—and shadows will fall behind you.\" - Walt Whitman",
                    "\"The only way to achieve the impossible is to believe it is possible.\" - Charles Kingsleigh",
                    "\"What we achieve inwardly will change outer reality.\" - Plutarch",
                    "\"Success is the sum of small efforts, repeated day in and day out.\" - Robert Collier",
                    "\"The best revenge is massive success.\" - Frank Sinatra",
                    "\"To be successful, you have to have your heart in your business, and your business in your heart.\" - Thomas Watson Sr.",
                    "\"Success is not how high you have climbed, but how you make a positive difference to the world.\" - Roy T. Bennett",
                    "\"In order to succeed, we must first believe that we can.\" - Nikos Kazantzakis",
                    "\"The only thing standing between you and your goal is the story you keep telling yourself as to why you can't achieve it.\" - Jordan Belfort",
                    "\"Success is not the absence of failure; it's the persistence through failure.\" - Aisha Tyler",
                    "\"Great things are done by a series of small things brought together.\" - Vincent Van Gogh",
                    "\"Action is the foundational key to all success.\" - Pablo Picasso",
                    "\"Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going.\" - Chantal Sutherland",
                    "\"Perseverance is not a long race; it is many short races one after the other.\" - Walter Elliot",
                    "\"You don’t have to be great to start, but you have to start to be great.\" - Zig Ziglar",
                    "\"Challenges are what make life interesting and overcoming them is what makes life meaningful.\" - Joshua J. Marine",
                    "\"The secret of success is to do the common thing uncommonly well.\" - John D. Rockefeller Jr.",
                    "\"What lies behind us and what lies before us are tiny matters compared to what lies within us.\" - Ralph Waldo Emerson",
                    "\"Success is not final, failure is not fatal: It is the courage to continue that counts.\" - Winston Churchill"
                ]

                Text("\(quote)")
                    .font(.body)
                    .italic()
                    .onAppear(){
                        self.quote = quotes.randomElement() ?? "You got this!"
                    }

                VStack(spacing: 10) {
                    Button(action: {
                        showingEditHabit = true
                    }) {
                        Text("Edit Habit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .background(
                        NavigationLink(
                            destination: EditHabitView(habit: habit, habits: $habits),
                            isActive: $showingEditHabit,
                            label: { EmptyView() }
                        )
                        .hidden()
                    )

                    Button(action: {
                        showingHistory = true
                    }) {
                        Text("View History")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .background(
                        NavigationLink(
                            destination: HistoryView(completionDates: habit.formattedCompletionDates),
                            isActive: $showingHistory,
                            label: { EmptyView() }
                        )
                        .hidden()
                    )

                    Button(action: {
                        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
                            habits.remove(at: index)
                            if let currentUser = UserManager.shared.getUserByUsername(username) {
                                UserManager.shared.removeHabit(for: currentUser, habit: habit)
                            }
                        }
                    }) {
                        Text("Delete Habit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
            }
            .padding()
            .background(Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255))
            .foregroundColor(.white)
        }
        .background(Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255).edgesIgnoringSafeArea(.all))
    }
}
