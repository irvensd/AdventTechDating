import Foundation
import FirebaseFirestore

// Firestore collections structure
enum FirestoreCollections {
    static let users = "users"
    static let matches = "matches"
    static let messages = "messages"
    static let conversations = "conversations"
    static let reports = "reports"
    static let blocks = "blocks"
    
    // Subcollections
    static let photos = "photos"
    static let likes = "likes"
    static let views = "views"
}

struct Match: Codable, Identifiable {
    let id: String
    let users: [String] // Array of user IDs
    let timestamp: Date
    let status: MatchStatus
    
    enum MatchStatus: String, Codable {
        case pending
        case accepted
        case declined
    }
}

// Document structure for conversations
struct Conversation: Codable {
    let id: String
    let participants: [String]
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: [String: Int] // [userId: count]
} 