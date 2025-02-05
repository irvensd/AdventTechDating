import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @AppStorage("rememberMe") private var rememberMe = false
    @AppStorage("savedEmail") private var savedEmail = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("Welcome to Belovedly")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Where faith meets love")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .foregroundColor(.gray)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .foregroundColor(.gray)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textContentType(.password)
                    }
                    
                    // Forgot Password
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .foregroundColor(.yellow)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Remember Me Toggle
                    Toggle("Remember Me", isOn: $rememberMe)
                        .padding(.horizontal)
                    
                    // Sign In Button
                    Button(action: login) {
                        Text(authViewModel.isLoading ? "Signing in..." : "Sign In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(authViewModel.isLoading)
                    
                    // Error Message
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // Sign Up Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .foregroundColor(.yellow)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            if rememberMe {
                email = savedEmail
            }
        }
    }
    
    private func login() {
        Task {
            do {
                try await authViewModel.signIn(
                    withEmail: email,
                    password: password,
                    rememberMe: rememberMe
                )
            } catch {
                // Error will be handled by AuthViewModel
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
} 