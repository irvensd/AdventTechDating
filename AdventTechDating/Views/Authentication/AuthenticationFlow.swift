import SwiftUI
import FirebaseAuth

struct AuthenticationFlow: View {
    @State private var showSignUp = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and App Name with animation
            VStack(spacing: 20) {
                Image(systemName: "heart.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.yellow)
                    .rotationEffect(.degrees(authViewModel.isLoading ? 360 : 0))
                    .animation(
                        authViewModel.isLoading ? 
                            Animation.linear(duration: 2).repeatForever(autoreverses: false) : 
                            .default,
                        value: authViewModel.isLoading
                    )
                
                Text("Belovedly")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Find your faithful companion")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            
            if authViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }
            
            Spacer()
            
            // Sign In/Sign Up Buttons
            VStack(spacing: 16) {
                Button(action: { 
                    withAnimation {
                        showSignUp = false
                    }
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .buttonStyle(BounceButtonStyle())
                
                Button(action: { 
                    withAnimation {
                        showSignUp = true
                    }
                }) {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                }
                .buttonStyle(BounceButtonStyle())
                
                // Force Logout Button (only in debug)
                #if DEBUG
                Button(action: forceLogout) {
                    Text("Force Logout (Debug)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                #endif
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: .constant(!showSignUp)) {
            LoginView()
                .environmentObject(authViewModel)
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .onChange(of: authViewModel.errorMessage) { newError in
            if let error = newError {
                errorMessage = error
                showingError = true
            }
        }
    }
    
    private func forceLogout() {
        do {
            try Auth.auth().signOut()
            authViewModel.userSession = nil
            authViewModel.currentUser = nil
        } catch {
            print("Debug: Force logout error - \(error.localizedDescription)")
        }
    }
}

// Preview for testing
struct AuthenticationFlow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal state
            AuthenticationFlow()
                .environmentObject(AuthViewModel())
            
            // Loading state
            AuthenticationFlow()
                .environmentObject({
                    let vm = AuthViewModel()
                    vm.isLoading = true
                    return vm
                }())
            
            // Error state
            AuthenticationFlow()
                .environmentObject({
                    let vm = AuthViewModel()
                    vm.errorMessage = "Test error message"
                    return vm
                }())
        }
    }
} 
