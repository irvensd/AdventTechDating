import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import Foundation

@MainActor
class PrayerPartnersViewModel: ObservableObject {
    @Published var userProfile: PrayerPartner
    @Published var activePrayerPartners: [PrayerPartner] = []
    @Published var potentialMatches: [PrayerPartner] = []
    @Published var isProfileComplete = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init() {
        // Initialize with empty profile
        self.userProfile = PrayerPartner(
            id: UUID().uuidString,
            userId: Auth.auth().currentUser?.uid ?? "",
            name: "",
            prayerInterests: [],
            preferredTime: .flexible,
            prayerFrequency: .weekly,
            bio: "",
            isAvailable: true
        )
        
        Task {
            await loadUserProfile()
        }
    }
    
    func loadUserProfile() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let doc = try await db.collection("prayerPartners").document(userId).getDocument()
            if let profile = try? doc.data(as: PrayerPartner.self) {
                self.userProfile = profile
                self.isProfileComplete = true
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func findMatches() async {
        isLoading = true
        
        do {
            let snapshot = try await db.collection("prayerPartners")
                .whereField("isAvailable", isEqualTo: true)
                .whereField("userId", isNotEqualTo: userProfile.userId)
                .getDocuments()
            
            let allPartners = snapshot.documents.compactMap { try? $0.data(as: PrayerPartner.self) }
            
            // Filter and sort by compatibility
            self.potentialMatches = allPartners
                .filter { partner in
                    // Must have at least one common prayer interest
                    !Set(partner.prayerInterests).intersection(Set(userProfile.prayerInterests)).isEmpty
                }
                .sorted { partner1, partner2 in
                    // Sort by number of matching interests
                    let matches1 = Set(partner1.prayerInterests).intersection(Set(userProfile.prayerInterests)).count
                    let matches2 = Set(partner2.prayerInterests).intersection(Set(userProfile.prayerInterests)).count
                    return matches1 > matches2
                }
            
            isLoading = false
        } catch {
            isLoading = false
            self.error = error.localizedDescription
        }
    }
    
    func updateProfile(_ profile: PrayerPartner) async throws {
        do {
            try await db.collection("prayerPartners")
                .document(profile.userId)
                .setData(from: profile)
            
            self.userProfile = profile
            self.isProfileComplete = true
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }
    
    func sendPrayerRequest(to partner: PrayerPartner, message: String) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let request = [
            "fromUserId": currentUserId,
            "toUserId": partner.userId,
            "message": message,
            "status": "pending",
            "timestamp": Timestamp()
        ] as [String : Any]
        
        try await db.collection("prayerRequests").addDocument(data: request)
    }
} 