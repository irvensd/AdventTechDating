import Foundation

extension UserDefaults {
    private enum Keys {
        static let collapsedComments = "collapsedComments"
    }
    
    var collapsedCommentIds: [String] {
        get {
            stringArray(forKey: Keys.collapsedComments) ?? []
        }
        set {
            set(newValue, forKey: Keys.collapsedComments)
        }
    }
    
    func isCommentCollapsed(_ commentId: UUID) -> Bool {
        collapsedCommentIds.contains(commentId.uuidString)
    }
    
    func toggleCommentCollapsed(_ commentId: UUID) {
        var ids = collapsedCommentIds
        if let index = ids.firstIndex(of: commentId.uuidString) {
            ids.remove(at: index)
        } else {
            ids.append(commentId.uuidString)
        }
        collapsedCommentIds = ids
    }
} 