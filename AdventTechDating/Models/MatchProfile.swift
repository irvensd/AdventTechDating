import Foundation

struct MatchProfile: Identifiable, Codable {
    let id: String
    let name: String
    let photoURL: String?
    let lastActive: Date
    let matchDate: Date
    let userId: String
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: matchDate, relativeTo: Date())
    }
} 