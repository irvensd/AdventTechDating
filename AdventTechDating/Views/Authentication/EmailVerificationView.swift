import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isCheckingVerification = false
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "envelope.badge")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
                .padding(.top, 50)
            
            Text("Verify your email")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We've sent a verification email to:")
                .foregroundColor(.gray)
            
            Text(authViewModel.currentUser?.email ?? "")
                .font(.headline)
            
            Text("Please check your inbox and click the verification link to continue")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            if isCheckingVerification {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await checkVerification()
                    }
                }) {
                    Text("I've verified my email")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    Task {
                        await resendVerificationEmail()
                    }
                }) {
                    Text("Resend verification email")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .foregroundColor(.yellow)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                }
                
                Button(action: {
                    try? authViewModel.signOut()
                }) {
                    Text("Sign out")
                        .foregroundColor(.gray)
                }
                .padding(.top)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
        }
        .alert("Verification Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onReceive(timer) { _ in
            Task {
                await authViewModel.checkEmailVerification()
            }
        }
    }
    
    private func checkVerification() async {
        isCheckingVerification = true
        await authViewModel.checkEmailVerification()
        isCheckingVerification = false
        
        if authViewModel.isEmailVerified {
            alertMessage = "Email verified successfully!"
        } else {
            alertMessage = "Email not verified yet. Please check your inbox and click the verification link."
        }
        showAlert = true
    }
    
    private func resendVerificationEmail() async {
        do {
            try await authViewModel.resendVerificationEmail()
            alertMessage = "Verification email sent successfully!"
            showAlert = true
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

#Preview {
    EmailVerificationView()
        .environmentObject(AuthViewModel())
} 