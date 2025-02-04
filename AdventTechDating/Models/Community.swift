import Foundation

struct Community: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let description: String
    let icon: String
    var members: Int
    var posts: Int
    var isPrivate: Bool
    var rules: [String]
    var admins: [String]
    
    static let categories = [
        "Ministry Groups",
        "Bible Study",
        "Prayer Groups",
        "Health & Lifestyle",
        "Music Ministry",
        "Youth Ministry",
        "Outreach",
        "Social"
    ]
}

// Sample Data
let sampleCommunities = [
    Community(
        name: "Advent Prayer Warriors",
        category: "Prayer Groups",
        description: "A community dedicated to prayer and spiritual growth",
        icon: "hands.sparkles.fill",
        members: 150,
        posts: 45,
        isPrivate: false,
        rules: ["Be respectful", "No spam", "Keep it spiritual"],
        admins: ["Sarah Johnson"]
    ),
    Community(
        name: "Bible Study Fellowship",
        category: "Bible Study",
        description: "Deep dive into Scripture with fellow believers",
        icon: "book.fill",
        members: 89,
        posts: 120,
        isPrivate: false,
        rules: ["Focus on Scripture", "Respectful discussions", "No off-topic posts"],
        admins: ["David Chen"]
    ),
    Community(
        name: "Health & Wellness",
        category: "Health & Lifestyle",
        description: "Living the Adventist health message",
        icon: "heart.fill",
        members: 234,
        posts: 180,
        isPrivate: false,
        rules: ["Evidence-based discussions", "No product promotion", "Support others"],
        admins: ["Maria Santos"]
    ),
    Community(
        name: "Youth Ministry Connect",
        category: "Youth Ministry",
        description: "Connecting young Adventists worldwide",
        icon: "person.3.fill",
        members: 567,
        posts: 340,
        isPrivate: false,
        rules: ["Age 16-30", "Keep it clean", "Be supportive"],
        admins: ["James Wilson"]
    ),
    Community(
        name: "Music & Worship",
        category: "Music Ministry",
        description: "Share and discuss worship music",
        icon: "music.note",
        members: 198,
        posts: 230,
        isPrivate: false,
        rules: ["Appropriate content", "Credit original artists", "No debates"],
        admins: ["Rachel Kim"]
    )
] 