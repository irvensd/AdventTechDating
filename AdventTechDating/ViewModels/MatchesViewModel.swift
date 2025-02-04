import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class MatchesViewModel: ObservableObject {
    @Published var matches: [MatchProfile] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init() {
        loadMatches()
    }
    
    private func loadMatches() {
        // For now, use sample data
        self.matches = [
            MatchProfile(
                id: "1",
                name: "Sarah",
                photoURL: nil,
                lastActive: Date(),
                matchDate: Date(),
                userId: "user1"
            ),
            MatchProfile(
                id: "2",
                name: "Rachel",
                photoURL: nil,
                lastActive: Date(),
                matchDate: Date(),
                userId: "user2"
            ),
            MatchProfile(
                id: "3",
                name: "Hannah",
                photoURL: nil,
                lastActive: Date(),
                matchDate: Date(),
                userId: "user3"
            )
        ]
    }
    
    func loadMatchesFromFirestore() async {
        isLoading = true
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        do {
            let snapshot = try await db.collection("matches")
                .whereField("users", arrayContains: currentUserId)
                .whereField("status", isEqualTo: "accepted")
                .getDocuments()
            
            let matchProfiles = try await fetchMatchProfiles(from: snapshot.documents)
            
            DispatchQueue.main.async {
                self.matches = matchProfiles
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func fetchMatchProfiles(from documents: [QueryDocumentSnapshot]) async throws -> [MatchProfile] {
        var profiles: [MatchProfile] = []
        
        for doc in documents {
            guard let match = try? doc.data(as: Match.self) else { continue }
            
            // Get the other user's ID (not current user)
            guard let otherUserId = match.users.first(where: { $0 != Auth.auth().currentUser?.uid }) else { continue }
            
            // Fetch other user's profile
            let userDoc = try await db.collection("users").document(otherUserId).getDocument()
            guard let userProfile = try? userDoc.data(as: UserProfile.self) else { continue }
            
            let matchProfile = MatchProfile(
                id: doc.documentID,
                name: "\(userProfile.firstName) \(userProfile.lastName)",
                photoURL: userProfile.photoURL,
                lastActive: userProfile.lastActive ?? Date(),
                matchDate: match.timestamp,
                userId: otherUserId
            )
            
            profiles.append(matchProfile)
        }
        
        return profiles
    }
} 