import Foundation

extension Notification.Name {
    static let newReply = Notification.Name("newReply")
}

struct CommentNotification {
    let parentComment: Post.Comment
    let reply: Post.Comment
    let authorName: String
    
    var body: String {
        "\(authorName) replied to your comment"
    }
} 