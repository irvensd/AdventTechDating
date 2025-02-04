import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isEmailVerified = false
    
    private let db = Firestore.firestore()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        
        if let userSession = userSession {
            Task {
                await fetchUser(withUid: userSession.uid)
            }
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        isLoading = true
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.isEmailVerified = result.user.isEmailVerified
            await fetchUser(withUid: result.user.uid)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
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
} 