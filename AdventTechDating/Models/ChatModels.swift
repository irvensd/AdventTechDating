import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let timestamp: Date
    var isRead: Bool
}

struct ChatConversation: Codable, Identifiable {
    let id: String
    let participants: [String]
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: [String: Int] // [userId: count]
} 