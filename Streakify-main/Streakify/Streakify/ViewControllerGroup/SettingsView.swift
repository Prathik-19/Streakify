import SwiftUI

// Define the colors globally in the file scope
let globalBackgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255)
let globalTextColor = Color.white
let globalButtonColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255)

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var enableNotifications = true
    @State private var progressBar = false
    @State private var privacyLevel = "Standard"

    let privacyOptions = ["Standard", "Enhanced", "Maximum"]

    var body: some View {
        NavigationView {
            ZStack {
                globalBackgroundColor.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 20) {
                        GroupBox(label: Label("General", systemImage: "gear").foregroundColor(globalTextColor)) {
                            Toggle("Progress Bar", isOn: $progressBar)
                                .toggleStyle(SwitchToggleStyle(tint: globalButtonColor))
                                .foregroundColor(globalTextColor)
                            
                            Text("Privacy Settings")
                                .font(.headline)
                                .foregroundColor(globalTextColor)
                                .padding(.top)

                            Picker("Privacy Level", selection: $privacyLevel) {
                                ForEach(privacyOptions, id: \.self) {
                                    Text($0).foregroundColor(globalTextColor)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .groupBoxStyle(SettingsGroupBoxStyle(backgroundColor: globalBackgroundColor, textColor: globalTextColor))

                        GroupBox(label: Label("Notifications", systemImage: "bell.fill").foregroundColor(globalTextColor)) {
                            Toggle("Enable Notifications", isOn: $enableNotifications)
                                .toggleStyle(SwitchToggleStyle(tint: globalButtonColor))
                                .foregroundColor(globalTextColor)
                        }
                        .groupBoxStyle(SettingsGroupBoxStyle(backgroundColor: globalBackgroundColor, textColor: globalTextColor))

                        GroupBox(label: Label("Support", systemImage: "person.crop.circle").foregroundColor(globalTextColor)) {
                            Button("Contact Support") {
                                print("Support tapped")
                            }
                            .foregroundColor(globalTextColor)
                        }
                        .groupBoxStyle(SettingsGroupBoxStyle(backgroundColor: globalBackgroundColor, textColor: globalTextColor))
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(globalTextColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(globalTextColor)
                }
            }
            .accentColor(globalButtonColor)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct SettingsGroupBoxStyle: GroupBoxStyle {
    let backgroundColor: Color
    let textColor: Color

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
                .padding()
                .background(backgroundColor)
                .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
        .background(RoundedRectangle(cornerRadius: 10).fill(backgroundColor.opacity(0.8)))
        .foregroundColor(textColor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
