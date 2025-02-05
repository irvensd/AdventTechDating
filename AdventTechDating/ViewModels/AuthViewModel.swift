import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isEmailVerified = false
    
    @AppStorage("rememberMe") private var rememberMe = false
    @AppStorage("savedEmail") private var savedEmail = ""
    
    private let db = Firestore.firestore()
    
    enum AuthError: LocalizedError {
        case weakPassword
        case emailAlreadyInUse
        case invalidEmail
        case userNotFound
        case wrongPassword
        case networkError
        case tooManyRequests
        case unknown(String)
        
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
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        
        if let userSession = userSession {
            Task {
                await fetchUser(withUid: userSession.uid)
            }
        }
    }
    
    func signIn(withEmail email: String, password: String, rememberMe: Bool) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.isEmailVerified = result.user.isEmailVerified
            
            // Handle Remember Me
            self.rememberMe = rememberMe
            if rememberMe {
                self.savedEmail = email
            } else {
                self.savedEmail = ""
            }
            
            await fetchUser(withUid: result.user.uid)
            isLoading = false
        } catch {
            isLoading = false
            throw mapFirebaseError(error)
        }
    }
    
    func createUser(email: String, password: String, firstName: String, lastName: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Send verification email
            try await result.user.sendEmailVerification()
            
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
            
            try await saveUserData(user)
            self.currentUser = user
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
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
    
    @MainActor
    func fetchUser(withUid uid: String) async {
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: UserProfile.self)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveUserData(_ user: UserProfile) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
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
    
    func checkEmailVerification() async {
        guard let user = Auth.auth().currentUser else { return }
        try? await user.reload()
        self.isEmailVerified = user.isEmailVerified
    }
    
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