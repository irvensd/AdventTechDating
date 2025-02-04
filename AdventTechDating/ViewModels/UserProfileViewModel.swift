import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    init() {
        fetchCurrentUserProfile()
    }
    
    func fetchCurrentUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                do {
                    if let snapshot = snapshot {
                        self?.userProfile = try snapshot.data(as: UserProfile.self)
                    }
                } catch {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateProfile(_ profile: UserProfile) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        do {
            try await db.collection("users").document(userId).setData(from: profile)
            DispatchQueue.main.async {
                self.userProfile = profile
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    func uploadProfilePhoto(imageData: Data) async -> String? {
        guard let userId = userProfile?.id else { return nil }
        
        let photoRef = storage.child("profile_photos/\(userId)/\(UUID().uuidString).jpg")
        
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await photoRef.putDataAsync(imageData, metadata: metadata)
            let url = try await photoRef.downloadURL()
            return url.absoluteString
        } catch {
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
} 