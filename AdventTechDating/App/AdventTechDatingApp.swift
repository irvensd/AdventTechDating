import SwiftUI
import FirebaseCore

@main
struct AdventTechDatingApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        // Initialize Firebase through our manager
        _ = FirebaseManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = authViewModel.userSession {
                    if !authViewModel.isEmailVerified {
                        EmailVerificationView()
                            .environmentObject(authViewModel)
                    } else {
                        ContentView()
                            .environmentObject(authViewModel)
                    }
                } else {
                    AuthenticationFlow()
                        .environmentObject(authViewModel)
                }
            }
            .navigationViewStyle(.stack)
            .accentColor(.yellow)
        }
    }
} 