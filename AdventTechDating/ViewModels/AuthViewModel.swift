import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    // These properties will automatically update the UI when changed
    @Published var userSession: FirebaseAuth.User?     // Current Firebase user session
    @Published var currentUser: UserProfile?           // User's profile data
    @Published var errorMessage: String?              // Error messages to display
    @Published var isLoading = false                  // Loading state for UI feedback
    @Published var isEmailVerified = false            // Email verification status
    
    // MARK: - Persistent Storage
    // UserDefaults storage for remember me functionality
    @AppStorage("rememberMe") private var rememberMe = false
    @AppStorage("savedEmail") private var savedEmail = ""
    
    private let db = Firestore.firestore()            // Firestore database reference
    
    // MARK: - Error Handling
    // Custom error types for better error messages
    enum AuthError: LocalizedError {
        case weakPassword
        case emailAlreadyInUse
        case invalidEmail
        case userNotFound
        case wrongPassword
        case networkError
        case tooManyRequests
        case unknown(String)
        
        // Human-readable error messages
        var errorDescription: String? {
            switch self {
            case .weakPassword:
                return "Please use a stronger password"
            case .emailAlreadyInUse:
                return "This email is already registered"
            case .invalidEmail:
                return "Please enter a valid email address"
            case .userNotFound:
                return "No account found with this email"
            case .wrongPassword:
                return "Incorrect password"
            case .networkError:
                return "Network error. Please check your connection"
            case .tooManyRequests:
                return "Too many attempts. Please try again later"
            case .unknown(let message):
                return message
            }
        }
    }
    
    // MARK: - Initialization
    // Check for existing session and fetch user data if logged in
    init() {
        self.userSession = Auth.auth().currentUser
        self.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        
        if let userSession = userSession {
            Task {
                await fetchUser(withUid: userSession.uid)
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Signs in a user with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - rememberMe: Whether to save email for future logins
    func signIn(withEmail email: String, password: String, rememberMe: Bool) async throws {
        isLoading = true
        do {
            // Attempt Firebase authentication
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.isEmailVerified = result.user.isEmailVerified
            
            // Handle Remember Me functionality
            self.rememberMe = rememberMe
            if rememberMe {
                self.savedEmail = email
            } else {
                self.savedEmail = ""
            }
            
            // Fetch user's profile data
            await fetchUser(withUid: result.user.uid)
            isLoading = false
        } catch {
            isLoading = false
            throw mapFirebaseError(error)
        }
    }
    
    /// Creates a new user account
    /// - Parameters:
    ///   - email: New user's email
    ///   - password: New user's password
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    func createUser(email: String, password: String, firstName: String, lastName: String) async throws {
        isLoading = true
        do {
            // Create Firebase auth account
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Send verification email
            try await result.user.sendEmailVerification()
            
            // Create user profile
            let user = UserProfile(
                id: result.user.uid,
                firstName: firstName,
                lastName: lastName,
                email: email,
                birthDate: Date(),
                createdAt: Date(),
                gender: nil,
                lookingFor: nil,
                profileCompleted: false
            )
            
            // Save user data to Firestore
            try await saveUserData(user)
            self.currentUser = user
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Signs out the current user
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - User Data Methods
    
    /// Fetches user profile data from Firestore
    @MainActor
    func fetchUser(withUid uid: String) async {
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: UserProfile.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// Saves user profile data to Firestore
    private func saveUserData(_ user: UserProfile) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    // MARK: - Password Reset & Verification
    
    /// Sends password reset email
    func resetPassword(email: String) async throws {
        isLoading = true
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Resends verification email to current user
    func resendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        do {
            try await user.sendEmailVerification()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    /// Checks if user's email is verified
    func checkEmailVerification() async {
        guard let user = Auth.auth().currentUser else { return }
        try? await user.reload()
        self.isEmailVerified = user.isEmailVerified
    }
    
    // MARK: - Error Mapping
    
    /// Converts Firebase errors to custom AuthError types
    private func mapFirebaseError(_ error: Error) -> Error {
        let authError = error as NSError
        switch authError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return AuthError.wrongPassword
        case AuthErrorCode.invalidEmail.rawValue:
            return AuthError.invalidEmail
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return AuthError.emailAlreadyInUse
        case AuthErrorCode.weakPassword.rawValue:
            return AuthError.weakPassword
        case AuthErrorCode.userNotFound.rawValue:
            return AuthError.userNotFound
        case AuthErrorCode.networkError.rawValue:
            return AuthError.networkError
        case AuthErrorCode.tooManyRequests.rawValue:
            return AuthError.tooManyRequests
        default:
            return AuthError.unknown(error.localizedDescription)
        }
    }
} 