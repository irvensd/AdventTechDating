import Foundation

struct Post: Identifiable, Codable {
    let id: UUID
    let authorId: String
    let authorName: String
    let communityId: UUID
    let content: String
    let timestamp: Date
    var likes: Int
    var comments: [Comment]
    var isLiked: Bool
    var isPinned: Bool
    let category: PostCategory
    var tags: [String]
    
    init(
        id: UUID = UUID(),
        authorId: String,
        authorName: String,
        communityId: UUID,
        content: String,
        timestamp: Date = Date(),
        likes: Int = 0,
        comments: [Comment] = [],
        isLiked: Bool = false,
        isPinned: Bool = false,
        category: PostCategory = .discussion,
        tags: [String] = []
    ) {
        self.id = id
        self.authorId = authorId
        self.authorName = authorName
        self.communityId = communityId
        self.content = content
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.isLiked = isLiked
        self.isPinned = isPinned
        self.category = category
        self.tags = tags
    }
    
    struct Comment: Identifiable, Codable {
        let id: UUID
        let authorId: String
        let authorName: String
        var content: String
        let timestamp: Date
        var likes: Int
        var likedBy: Set<String>
        var replies: [Comment]
        var parentId: UUID?
        var lastEditedAt: Date?
        
        init(
            id: UUID = UUID(),
            authorId: String,
            authorName: String,
            content: String,
            timestamp: Date = Date(),
            likes: Int = 0,
            likedBy: Set<String> = [],
            replies: [Comment] = [],
            parentId: UUID? = nil,
            lastEditedAt: Date? = nil
        ) {
            self.id = id
            self.authorId = authorId
            self.authorName = authorName
            self.content = content
            self.timestamp = timestamp
            self.likes = likes
            self.likedBy = likedBy
            self.replies = replies
            self.parentId = parentId
            self.lastEditedAt = lastEditedAt
        }
        
        enum SortOption: String, CaseIterable {
            case newest = "Newest"
            case oldest = "Oldest"
            case mostLiked = "Most Liked"
            case mostReplies = "Most Replies"
        }
        
        var isEdited: Bool {
            lastEditedAt != nil
        }
        
        var canEdit: Bool {
            // Allow editing for 24 hours
            guard let hoursAgo = Calendar.current.dateComponents([.hour], from: timestamp, to: Date()).hour else {
                return false
            }
            return hoursAgo < 24
        }
        
        var canDelete: Bool {
            // User can delete if they're the author
            authorId == "currentUser" // In a real app, compare with actual current user ID
        }
    }
    
    enum PostCategory: String, Codable, CaseIterable {
        case discussion = "Discussion"
        case question = "Question"
        case event = "Event"
        case announcement = "Announcement"
        case prayer = "Prayer Request"
        case testimony = "Testimony"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .discussion: return "bubble.left.and.bubble.right"
            case .question: return "questionmark.circle"
            case .event: return "calendar"
            case .announcement: return "megaphone"
            case .prayer: return "hands.sparkles"
            case .testimony: return "heart"
            case .other: return "ellipsis.circle"
            }
        }
    }
}

// Add some sample posts for testing
extension Post {
    static let samplePosts = [
        Post(
            authorId: "user1",
            authorName: "Sarah Johnson",
            communityId: sampleCommunities[0].id,
            content: "Join us for our weekly prayer meeting this Wednesday at 7 PM! We'll be focusing on community needs and supporting each other. Bring your prayer requests! 🙏",
            timestamp: Date(),
            likes: 0,
            comments: [
                Comment(
                    authorId: "user2",
                    authorName: "David Chen",
                    content: "I'll be there! Looking forward to it.",
                    likes: 5,
                    likedBy: ["user3", "user4"]
                ),
                Comment(
                    authorId: "user3",
                    authorName: "Maria Santos",
                    content: "Can we join virtually?",
                    likes: 3
                )
            ],
            category: .event,
            tags: ["prayer", "weekly", "community"]
        ),
        Post(
            authorId: "user2",
            authorName: "David Chen",
            communityId: sampleCommunities[0].id,
            content: "Looking for study partners for our upcoming Bible study series on Revelation. We'll meet twice a week and dive deep into scripture. Anyone interested? 📚",
            timestamp: Date(),
            likes: 0,
            comments: [
                Comment(
                    authorId: "user4",
                    authorName: "John Smith",
                    content: "I'm in! What days are you thinking?",
                    likes: 4,
                    replies: [
                        Comment(
                            authorId: "user2",
                            authorName: "David Chen",
                            content: "Thinking Tuesday and Thursday evenings. Would that work?",
                            parentId: UUID()
                        )
                    ]
                )
            ],
            category: .discussion,
            tags: ["bible-study", "revelation", "study-group"]
        ),
        Post(
            authorId: "user3",
            authorName: "Maria Santos",
            communityId: sampleCommunities[0].id,
            content: "Praise God for answered prayers! My mother's surgery was successful. Thank you everyone for your prayers and support during this difficult time. ❤️",
            timestamp: Date(),
            likes: 15,
            comments: [
                Comment(
                    authorId: "user5",
                    authorName: "Emily Wilson",
                    content: "So happy to hear this! God is good! 🙏",
                    likes: 8
                )
            ],
            category: .testimony,
            tags: ["praise", "testimony", "healing"]
        ),
        Post(
            authorId: "user4",
            authorName: "John Smith",
            communityId: sampleCommunities[1].id,
            content: "Just finished reading 'Mere Christianity' by C.S. Lewis. What an incredible book! Would love to discuss it with others who've read it. Any takers? 📖",
            timestamp: Date(),
            likes: 12,
            comments: [
                Comment(
                    authorId: "user6",
                    authorName: "Rachel Green",
                    content: "One of my favorites! The moral argument chapter really changed my perspective.",
                    likes: 6
                )
            ],
            category: .discussion,
            tags: ["books", "cs-lewis", "theology"]
        ),
        Post(
            authorId: "user5",
            authorName: "Emily Wilson",
            communityId: sampleCommunities[1].id,
            content: "Our youth group is organizing a beach cleanup this Saturday! Come join us in being good stewards of God's creation. 🌊 Meet at the church parking lot at 9 AM.",
            timestamp: Date(),
            likes: 20,
            comments: [
                Comment(
                    authorId: "user7",
                    authorName: "Michael Brown",
                    content: "Great initiative! I'll bring some extra trash bags.",
                    likes: 4
                )
            ],
            category: .event,
            tags: ["youth-group", "service", "environment"]
        ),
        Post(
            authorId: "user6",
            authorName: "Rachel Green",
            communityId: sampleCommunities[2].id,
            content: "Starting a new series on mental health and faith. Let's break the stigma and support each other. First meeting next Monday at 6 PM. 💚",
            timestamp: Date(),
            likes: 25,
            comments: [
                Comment(
                    authorId: "user8",
                    authorName: "Lisa Taylor",
                    content: "This is so needed! Thank you for organizing this.",
                    likes: 7,
                    replies: [
                        Comment(
                            authorId: "user6",
                            authorName: "Rachel Green",
                            content: "Happy to help! We'll have professional counselors joining us too.",
                            parentId: UUID()
                        )
                    ]
                )
            ],
            category: .announcement,
            tags: ["mental-health", "support", "faith"]
        )
    ]
} 