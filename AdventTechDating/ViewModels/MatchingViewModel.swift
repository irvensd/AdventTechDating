import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

@MainActor
class MatchingViewModel: ObservableObject {
    @Published var potentialMatches: [UserProfile] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentProfile: UserProfile?
    
    private let db = Firestore.firestore()
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    private let maxDistance: Double = 100 // miles
    private let batchSize = 10
    private var lastDocument: DocumentSnapshot?
    
    init() {
        setupLocationUpdates()
    }
    
    private func setupLocationUpdates() {
        locationManager.$location
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self = self else { return }
                Task {
                    await self.fetchNearbyProfiles()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchNearbyProfiles() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let currentLocation = locationManager.location
            let center = GeoPoint(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            )
            
            // Get already liked/disliked profiles
            let interactions = try await fetchUserInteractions()
            let excludedIds = interactions.map { $0.targetUserId }
            
            // Query for nearby profiles
            var query = db.collection("users")
                .whereField("profileCompleted", isEqualTo: true)
                .whereField("isActive", isEqualTo: true)
                .limit(to: batchSize)
            
            if let last = lastDocument {
                query = query.start(afterDocument: last)
            }
            
            let snapshot = try await query.getDocuments()
            lastDocument = snapshot.documents.last
            
            let profiles = try snapshot.documents.compactMap { document -> UserProfile? in
                let profile = try document.data(as: UserProfile.self)
                
                // Skip if already interacted with
                guard !excludedIds.contains(profile.id) else { return nil }
                
                // Calculate distance
                guard let profileLocation = profile.location else { return nil }
                let distance = calculateDistance(from: center, to: profileLocation)
                
                // Skip if too far
                guard distance <= maxDistance else { return nil }
                
                return profile
            }
            
            // Apply matching algorithm
            let rankedProfiles = await rankProfiles(profiles)
            
            // Update UI
            DispatchQueue.main.async {
                self.potentialMatches.append(contentsOf: rankedProfiles)
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func rankProfiles(_ profiles: [UserProfile]) async -> [UserProfile] {
        guard let currentUser = currentProfile else { return profiles }
        
        // Calculate match scores
        let scoredProfiles = profiles.map { profile -> (UserProfile, Double) in
            var score: Double = 0
            
            // Faith compatibility (highest weight)
            if profile.denomination == currentUser.denomination {
                score += 30
            }
            
            // Interests overlap
            if let userInterests = currentUser.interests,
               let profileInterests = profile.interests {
                let commonInterests = Set(userInterests).intersection(Set(profileInterests))
                score += Double(commonInterests.count) * 5
            }
            
            // Ministry interests overlap
            if let userMinistry = currentUser.ministryInterests,
               let profileMinistry = profile.ministryInterests {
                let commonMinistry = Set(userMinistry).intersection(Set(profileMinistry))
                score += Double(commonMinistry.count) * 5
            }
            
            // Distance factor (closer is better)
            if let userLocation = currentUser.location,
               let profileLocation = profile.location {
                let distance = calculateDistance(from: userLocation, to: profileLocation)
                score += (100 - min(distance, 100)) * 0.2 // Max 20 points for distance
            }
            
            return (profile, score)
        }
        
        // Sort by score and return profiles
        return scoredProfiles
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
    
    private func calculateDistance(from point1: GeoPoint, to point2: GeoPoint) -> Double {
        let location1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
        let location2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
        
        return location1.distance(from: location2) * 0.000621371 // Convert meters to miles
    }
    
    func handleSwipe(_ direction: SwipeDirection, on profile: UserProfile) async {
        guard let currentUserId = currentProfile?.id else { return }
        
        let interaction = ProfileInteraction(
            userId: currentUserId,
            targetUserId: profile.id,
            type: direction == .right ? .like : .dislike,
            timestamp: Date()
        )
        
        do {
            try await saveInteraction(interaction)
            
            // Check for match if it's a like
            if direction == .right {
                try await checkForMatch(with: profile)
            }
            
            // Remove profile from potential matches
            DispatchQueue.main.async {
                self.potentialMatches.removeAll { $0.id == profile.id }
            }
            
            // Fetch more profiles if needed
            if potentialMatches.count < 5 {
                await fetchNearbyProfiles()
            }
            
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func saveInteraction(_ interaction: ProfileInteraction) async throws {
        try await db.collection("interactions")
            .document(UUID().uuidString)
            .setData(from: interaction)
    }
    
    private func checkForMatch(with profile: UserProfile) async throws {
        let query = db.collection("interactions")
            .whereField("userId", isEqualTo: profile.id)
            .whereField("targetUserId", isEqualTo: currentProfile?.id ?? "")
            .whereField("type", isEqualTo: ProfileInteraction.InteractionType.like.rawValue)
        
        let snapshot = try await query.getDocuments()
        
        if !snapshot.documents.isEmpty {
            // It's a match!
            try await createMatch(with: profile)
        }
    }
    
    private func createMatch(with profile: UserProfile) async throws {
        guard let currentUserId = currentProfile?.id else { return }
        
        let match = Match(
            id: UUID().uuidString,
            users: [currentUserId, profile.id],
            timestamp: Date(),
            status: .pending
        )
        
        try await db.collection("matches")
            .document(match.id)
            .setData(from: match)
    }
    
    private func fetchUserInteractions() async throws -> [ProfileInteraction] {
        guard let currentUserId = currentProfile?.id else { return [] }
        
        let snapshot = try await db.collection("interactions")
            .whereField("userId", isEqualTo: currentUserId)
            .getDocuments()
        
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: ProfileInteraction.self)
        }
    }
}

struct ProfileInteraction: Codable {
    let userId: String
    let targetUserId: String
    let type: InteractionType
    let timestamp: Date
    
    enum InteractionType: String, Codable {
        case like
        case dislike
        case superlike
    }
} 