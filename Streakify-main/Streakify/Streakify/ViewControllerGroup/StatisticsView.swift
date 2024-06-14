import SwiftUI

struct StatisticsView: View {
    var habits: [Habit]
    
    private var averageProgress: CGFloat {
        habits.map { $0.progress }.reduce(0, +) / CGFloat(habits.count)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Overall Progress")
                    .font(.title)
                    .padding()
                
                ProgressView(value: Double(averageProgress), total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding()
                
                Text("\(Int(averageProgress * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
            }
            .navigationBarTitle("Your Statistics", displayMode: .inline)
        }
    }
}
