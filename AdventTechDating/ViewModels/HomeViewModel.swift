import SwiftUI
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var profiles: [UserProfile] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    init() {
        loadProfiles()
    }
    
    private func loadProfiles() {
        // For now, use sample data
        self.profiles = SampleData.profiles
    }
    
    func likeProfile(_ profile: UserProfile) {
        // Implement like functionality
    }
    
    func dislikeProfile(_ profile: UserProfile) {
        // Implement dislike functionality
    }
} 