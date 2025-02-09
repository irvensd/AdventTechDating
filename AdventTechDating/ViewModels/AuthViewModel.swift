import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import FirebaseStorage

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    // These properties automatically update the UI when changed
    @Published var userSession: FirebaseAuth.User?     // Tracks current Firebase user session
    @Published var currentUser: UserProfile?           // Stores the user's complete profile data
    @Published var errorMessage: String?               // Holds error messages for display
    @Published var isLoading = false                   // Loading state for UI feedback
    @Published var isEmailVerified = false            // Tracks email verification status
    @Published var profileCompletionStatus: ProfileCompletionStatus = .incomplete
    @Published var requiredFieldsCompleted: Set<ProfileField> = []
    
    // MARK: - Persistent Storage
    // UserDefaults for remembering user login preferences
    @AppStorage("rememberMe") private var rememberMe = false
    @AppStorage("savedEmail") private var savedEmail = ""
    
    // Firebase Firestore reference
    private let db = Firestore.firestore()
    
    // MARK: - Error Handling
    // Custom error types for better user feedback
    enum AuthError: LocalizedError {
        case weakPassword
        case emailAlreadyInUse
        case invalidEmail
        case userNotFound
        case wrongPassword
        case networkError
        case tooManyRequests
        case unknown(String)
        
        // Human-readable error descriptions
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
    
    // MARK: - Authentication Methods
    
    /// Signs in user with email and password
    func signIn(withEmail email: String, password: String, rememberMe: Bool) async throws {
        isLoading = true
        do {
            // Attempt Firebase authentication
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            
            // Save email if remember me is enabled
            if rememberMe {
                self.savedEmail = email
                self.rememberMe = true
            }
            
            // Fetch user profile after successful login
            try await fetchUserProfile()
            
            isLoading = false
        } catch {
            isLoading = false
            throw mapFirebaseError(error)
        }
    }
    
    /// Creates new user account and profile
    func createUser(email: String, password: String, firstName: String, lastName: String) async throws {
        isLoading = true
        do {
            // Create Firebase auth account
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            // Create initial user profile
            let user = UserProfile(
                id: result.user.uid,
                firstName: firstName,
                lastName: lastName,
                email: email,
                birthDate: Date(),
                createdAt: Date()
            )
            
            // Save profile to Firestore
            try await db.collection("users").document(result.user.uid).setData(from: user)
            self.currentUser = user
            
            // Send verification email
            try await result.user.sendEmailVerification()
            
            isLoading = false
        } catch {
            isLoading = false
            throw mapFirebaseError(error)
        }
    }
    
    /// Fetches user profile from Firestore
    private func fetchUserProfile() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await db.collection("users").document(uid).getDocument()
        self.currentUser = try snapshot.data(as: UserProfile.self)
    }
    
    /// Signs out current user
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            if !rememberMe {
                self.savedEmail = ""
            }
        } catch {
            throw error
        }
    }
    
    /// Sends password reset email
    func resetPassword(email: String) async throws {
        isLoading = true
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            isLoading = false
            throw mapFirebaseError(error)
        }
    }
    
    /// Resends verification email
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
    
    /// Maps Firebase errors to custom AuthError types
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
    
    /// Updates profile completion status
    func updateProfileCompletion() {
        guard let profile = currentUser else {
            profileCompletionStatus = .incomplete
            return
        }
        
        // Check required fields
        var completedFields: Set<ProfileField> = []
        
        // Check photos
        if profile.photoURL != nil {
            completedFields.insert(.photos)
        }
        
        // Check bio
        if let bio = profile.bio, !bio.isEmpty {
            completedFields.insert(.bio)
        }
        
        // Check interests
        if let interests = profile.interests, !interests.isEmpty {
            completedFields.insert(.interests)
        }
        
        // Check faith values
        if profile.baptized != nil && profile.denomination != nil {
            completedFields.insert(.faith)
        }
        
        // Check location
        if profile.location != nil {
            completedFields.insert(.location)
        }
        
        // Update completion status
        self.requiredFieldsCompleted = completedFields
        
        let completionPercentage = Double(completedFields.count) / Double(ProfileField.allCases.count)
        
        switch completionPercentage {
        case 1.0:
            profileCompletionStatus = .complete
        case 0.5..<1.0:
            profileCompletionStatus = .basic
        default:
            profileCompletionStatus = .incomplete
        }
        
        // Update profile completion status in Firestore
        Task {
            try? await updateProfileCompletionStatus()
        }
    }
    
    /// Updates profile completion status in Firestore
    private func updateProfileCompletionStatus() async throws {
        guard let userId = userSession?.uid else { return }
        
        let data: [String: Any] = [
            "profileCompleted": profileCompletionStatus == .complete,
            "completedFields": Array(requiredFieldsCompleted.map { $0.rawValue })
        ]
        
        try await db.collection("users").document(userId).updateData(data)
    }
    
    /// Uploads profile photo to Firebase Storage
    func uploadProfilePhoto(_ imageData: Data) async throws -> String {
        guard let userId = userSession?.uid else {
            throw AuthError.unknown("No authenticated user")
        }
        
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("profile_photos/\(userId)/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await photoRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await photoRef.downloadURL()
        
        // Update user profile with photo URL
        try await db.collection("users").document(userId).updateData([
            "photoURL": downloadURL.absoluteString
        ])
        
        // Update local user profile
        currentUser?.photoURL = downloadURL.absoluteString
        
        // Update completion status
        updateProfileCompletion()
        
        return downloadURL.absoluteString
    }
    
    /// Updates user profile fields
    func updateProfile(_ updates: [String: Any]) async throws {
        guard let userId = userSession?.uid else {
            throw AuthError.unknown("No authenticated user")
        }
        
        try await db.collection("users").document(userId).updateData(updates)
        
        // Refresh user profile
        try await fetchUserProfile()
        
        // Update completion status
        updateProfileCompletion()
    }
}

enum ProfileCompletionStatus {
    case incomplete
    case basic
    case complete
    
    var description: String {
        switch self {
        case .incomplete: return "Profile Incomplete"
        case .basic: return "Basic Profile"
        case .complete: return "Profile Complete"
        }
    }
}

enum ProfileField: String, CaseIterable {
    case photos
    case bio
    case interests
    case faith
    case location
    case preferences
    
    var description: String {
        switch self {
        case .photos: return "Profile Photos"
        case .bio: return "About Me"
        case .interests: return "Interests"
        case .faith: return "Faith & Values"
        case .location: return "Location"
        case .preferences: return "Preferences"
        }
    }
} 