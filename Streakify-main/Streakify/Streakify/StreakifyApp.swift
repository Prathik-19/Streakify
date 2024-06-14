//
//  StreakifyApp.swift
//  StreakifyApp
//
//

import SwiftUI

@main
struct StreakifyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showLogin = true

    var body: some View {
        if showLogin {
            LoginView(showLogin: $showLogin)
        } else {
            SignUpView(showLogin: $showLogin)
        }
    }
}
