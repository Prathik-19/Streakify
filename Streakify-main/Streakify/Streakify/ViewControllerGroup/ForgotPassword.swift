import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var newPassword: String = ""
    
    
    let backgroundColor = Color(red: 11 / 255, green: 37 / 255, blue: 64 / 255) // Hex #0b2540
    let darkTealColor = Color(red: 5 / 255, green: 102 / 255, blue: 141 / 255) // Hex #05668d
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Reset Your Password")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Name", text: $name)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color.white.opacity(1))
                    .cornerRadius(5.0)
                    .padding(.bottom, 15)
                
                Button("Set New Password") {
                    // Verifies user and sets new password
                    setNewPassword()
                }
                .foregroundColor(.white)
                .padding()
                .background(darkTealColor)
                .cornerRadius(5.0)
                .padding(.bottom, 30)
                
                Button("Back to Login") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Recovery"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    private func setNewPassword() {
        guard let user = UserManager.shared.getUserByUsername(username),
              user.email == email,
              user.name == name else {
            alertMessage = "User information does not match."
            showAlert = true
            return
        }
        // Set the new password
        UserManager.shared.updateUserPassword(username: username, newPassword: newPassword)
        alertMessage = "Your password has been updated."
        showAlert = true
    }
}
        
//    private func displayPassword() {
//            guard let user = UserManager.shared.getUserByUsername(username),
//                  user.email == email,
//                  user.name == name else {
//                alertMessage = "User information does not match."
//                showAlert = true
//                return
//            }
//            
//            alertMessage = "Your password is: \(user.password)" //Password is hashed.
//            showAlert = true
//        }

// Preview for ForgotPasswordView
struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
