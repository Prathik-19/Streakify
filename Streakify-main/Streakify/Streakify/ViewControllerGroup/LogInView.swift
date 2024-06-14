import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var navigatingToMainPage = false
    @State private var navigatingToSignUp = false
    @State private var navigatingToForgotPassword = false
    @State private var showLoginError = false
    
    @State private var loggedInUser: Database? = nil
    
    @Binding var showLogin: Bool
    
    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255)
    let darkTealColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    Image("Image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipped()
                        .padding(.bottom, 20)
                    
                    Text("Welcome To Streakify!")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                    
                    Text("Building Better Habits Daily")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.bottom, 25)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(1))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(1))
                        .cornerRadius(5.0)
                        .padding(.bottom, 5)
                    
                    if showLoginError {
                        Text("Invalid username or password")
                            .foregroundColor(.red)
                            .padding(.bottom, 10)
                    }
                    
                    Button(action: {
                        navigatingToForgotPassword = true
                    }, label: {
                        Text("Forgot password?")
                            .foregroundColor(.white)
                            .padding(.bottom, 30)
                    })
                    
                    Button(action: {
                        showLoginError = false // Reset the error state
                        UserManager.shared.loginUser(username: username, password: password) { success, user in
                            if success {
                                loggedInUser = user
                                navigatingToMainPage = true
                            } else {
                                showLoginError = true
                            }
                        }
                    }, label: {
                        Text("Login")
                            .foregroundColor(.white)
                            .padding()
                            .background(darkTealColor)
                            .cornerRadius(5.0)
                            .padding(.bottom, 15)
                    })
                    
                    Button(action: {
                        navigatingToSignUp = true
                    }, label: {
                        Text("Need an account? Sign Up Here!")
                            .foregroundColor(.white)
                    })
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    // Fixes bug that keeps the information same if u go back to page
                    username = ""
                    password = ""
                    showLoginError = false
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
            .accentColor(.white)
            .background(
                NavigationLink(
                    destination: ForgotPasswordView(),
                    isActive: $navigatingToForgotPassword,
                    label: { EmptyView() }
                )
            )
            .background(
                NavigationLink(
                    destination: MainPageView(username: username),
                    isActive: $navigatingToMainPage,
                    label: { EmptyView() }
                )
            )
            .background(
                NavigationLink(
                    destination: SignUpView(showLogin: $showLogin),
                    isActive: $navigatingToSignUp,
                    label: { EmptyView() }
                )
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showLogin: .constant(true))
    }
}
