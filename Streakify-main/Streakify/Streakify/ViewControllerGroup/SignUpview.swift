import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showSignUpError = false
    
    @Binding var showLogin: Bool
    
    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255)
    let darkTealColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack {
                Image("Image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipped()
                    .padding(.bottom, 20)
                
                Text("Create Your Account")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                    .autocapitalization(.words)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                    .autocapitalization(.none)
                    .textContentType(.username)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                    .textContentType(.newPassword) // Set to .newPassword to avoid auto-suggestions
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .textContentType(.newPassword) // Set to .newPassword to avoid auto-suggestions
                
                if showSignUpError {
                    Text("Sign up failed. Please try again.")
                        .foregroundColor(.red)
                        .padding(.bottom, 10)
                }
                
                Button("Sign Up") {
                    if password == confirmPassword {
                        UserManager.shared.createUser(name: name, username: username, email: email, password: password) { success in
                            if success {
                                print("User created successfully")
                                showLogin = true
                                dismiss()
                            } else {
                                showSignUpError = true
                            }
                        }
                    } else {
                        showSignUpError = true
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(darkTealColor)
                .cornerRadius(5.0)
                .padding(.bottom, 10)
                
                Button("Already have an account? Log in") {
                    showLogin = true
                    dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showLogin: .constant(false))
    }
}
