import Foundation
import Combine
import UIKit

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Post.Comment] = []
    @Published var sortOption: Post.Comment.SortOption = .newest
    @Published var isLoading = false
    @Published var error: String?
    
    private let post: Post
    private let cache = NSCache<NSString, NSArray>()
    private let backupManager = CommentBackupManager.shared
    private var lastSyncTimestamp: Date?
    private let currentUserId = "currentUser" // In a real app, this would come from auth
    private var parentViewModel: CommunityViewModel? // Add this to update parent
    
    init(post: Post, parentViewModel: CommunityViewModel? = nil) {
        self.post = post
        self.parentViewModel = parentViewModel
        self.cache.name = "comments_cache"
        self.comments = post.comments
        loadComments()
    }
    
    var sortedComments: [Post.Comment] {
        sortComments(comments, by: sortOption)
    }
    
    private func sortComments(_ comments: [Post.Comment], by option: Post.Comment.SortOption) -> [Post.Comment] {
        var sorted = comments
        switch option {
        case .newest:
            sorted.sort { $0.timestamp > $1.timestamp }
        case .oldest:
            sorted.sort { $0.timestamp < $1.timestamp }
        case .mostLiked:
            sorted.sort { $0.likes > $1.likes }
        case .mostReplies:
            sorted.sort { $0.replies.count > $1.replies.count }
        }
        
        // Sort replies recursively
        return sorted.map { comment in
            var sortedComment = comment
            sortedComment.replies = sortComments(comment.replies, by: option)
            return sortedComment
        }
    }
    
    // MARK: - Loading & Caching
    
    func loadComments() {
        isLoading = true
        
        // First try cache
        if let cachedComments = loadFromCache() {
            self.comments = cachedComments
            isLoading = false
            return
        }
        
        // First try to load from post comments key
        if let data = UserDefaults.standard.data(forKey: "post_comments_\(post.id.uuidString)"),
           let decoded = try? JSONDecoder().decode([Post.Comment].self, from: data) {
            self.comments = decoded
            saveToCache(comments)
            isLoading = false
            return
        }
        
        // Fallback to regular comments
        if let data = UserDefaults.standard.data(forKey: "comments_\(post.id.uuidString)"),
           let decoded = try? JSONDecoder().decode([Post.Comment].self, from: data) {
            self.comments = decoded
            saveToCache(comments)
        }
        
        isLoading = false
        syncComments() // Try to sync after loading
    }
    
    private func loadFromCache() -> [Post.Comment]? {
        if let cachedArray = cache.object(forKey: cacheKey) as? NSArray {
            return cachedArray as? [Post.Comment]
        }
        return nil
    }
    
    private func saveToCache(_ comments: [Post.Comment]) {
        cache.setObject(comments as NSArray, forKey: cacheKey)
    }
    
    private var cacheKey: NSString {
        "comments_\(post.id.uuidString)" as NSString
    }
    
    // MARK: - Sync
    
    func syncComments() {
        guard let lastSync = lastSyncTimestamp else {
            lastSyncTimestamp = Date()
            return
        }
        
        // Only sync if more than 5 minutes have passed
        guard Date().timeIntervalSince(lastSync) > 300 else { return }
        
        // Here you would typically sync with your backend
        // For now, we'll just backup locally
        backupComments()
        lastSyncTimestamp = Date()
    }
    
    // MARK: - Backup & Recovery
    
    private func backupComments() {
        backupManager.saveBackup(comments, for: post.id)
    }
    
    func restoreFromBackup() {
        if let restored = backupManager.loadBackup(for: post.id) {
            self.comments = restored
            saveComments()
            saveToCache(restored)
        }
    }
    
    private func saveComments() {
        do {
            let encoded = try JSONEncoder().encode(comments)
            UserDefaults.standard.set(encoded, forKey: "comments_\(post.id.uuidString)")
            UserDefaults.standard.synchronize()
            
            // Also save to post comments key
            UserDefaults.standard.set(encoded, forKey: "post_comments_\(post.id.uuidString)")
            UserDefaults.standard.synchronize()
            
            saveToCache(comments)
            backupComments()
        } catch {
            self.error = "Failed to save comments: \(error.localizedDescription)"
        }
    }
    
    func addReply(_ reply: Post.Comment) {
        if let parentId = reply.parentId {
            var found = false
            comments = comments.map { comment in
                var updatedComment = comment
                if !found && findAndAddReply(&updatedComment, reply: reply, parentId: parentId) {
                    found = true
                }
                return updatedComment
            }
            
            if !found {
                // If parent wasn't found, add as top-level comment
                var newReply = reply
                newReply.parentId = nil
                comments.insert(newReply, at: 0)
            }
        } else {
            comments.insert(reply, at: 0)
        }
        
        // Update UI first
        objectWillChange.send()
        
        // Save locally
        saveComments()
        
        // Update parent post's comments
        if let parentViewModel = parentViewModel {
            // Ensure we're on the main thread
            Task { @MainActor in
                parentViewModel.updatePostComments(postId: post.id, newComments: comments)
            }
        }
    }
    
    private func findAndAddReply(_ comment: inout Post.Comment, reply: Post.Comment, parentId: UUID) -> Bool {
        if comment.id == parentId {
            // Add reply to parent's replies
            comment.replies.append(reply)
            return true
        }
        
        // Check nested replies
        for index in comment.replies.indices {
            var updatedReply = comment.replies[index]
            if findAndAddReply(&updatedReply, reply: reply, parentId: parentId) {
                comment.replies[index] = updatedReply
                return true
            }
        }
        
        return false
    }
    
    // Make sure to save after any modifications
    func likeComment(_ comment: Post.Comment) {
        // Find and update the comment recursively
        comments = comments.map { rootComment in
            var updatedComment = rootComment
            if findAndUpdateLike(&updatedComment, commentId: comment.id) {
                objectWillChange.send()
                saveComments()
            }
            return updatedComment
        }
    }
    
    private func findAndUpdateLike(_ comment: inout Post.Comment, commentId: UUID) -> Bool {
        if comment.id == commentId {
            if comment.likedBy.contains(currentUserId) {
                // Unlike
                comment.likedBy.remove(currentUserId)
                comment.likes -= 1
            } else {
                // Like
                comment.likedBy.insert(currentUserId)
                comment.likes += 1
            }
            return true
        }
        
        // Check replies
        for index in comment.replies.indices {
            var updatedReply = comment.replies[index]
            if findAndUpdateLike(&updatedReply, commentId: commentId) {
                comment.replies[index] = updatedReply
                return true
            }
        }
        
        return false
    }
    
    func isCommentLiked(_ comment: Post.Comment) -> Bool {
        comment.likedBy.contains(currentUserId)
    }
    
    func editComment(_ comment: Post.Comment, _ newContent: String) {
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            comments[index].content = newContent
            comments[index].lastEditedAt = Date()
            objectWillChange.send()
            saveComments()
        }
    }
    
    private func provideFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func deleteComment(_ comment: Post.Comment) {
        // Only allow deletion if user is the author
        guard comment.canDelete else {
            self.error = "You can only delete your own comments"
            return
        }
        
        // Remove from top-level comments
        if comments.contains(where: { $0.id == comment.id }) {
            comments.removeAll(where: { $0.id == comment.id })
        } else {
            // Remove from nested replies
            comments = comments.map { rootComment in
                var updatedComment = rootComment
                _ = findAndDeleteReply(&updatedComment, commentId: comment.id)
                return updatedComment
            }
        }
        
        // Update UI
        objectWillChange.send()
        
        // Save changes
        saveComments()
        
        // Update parent post's comments
        if let parentViewModel = parentViewModel {
            Task { @MainActor in
                parentViewModel.updatePostComments(postId: post.id, newComments: comments)
            }
        }
        
        // Provide haptic feedback
        provideFeedback()
    }
    
    private func findAndDeleteReply(_ comment: inout Post.Comment, commentId: UUID) -> Bool {
        // Check direct replies
        if comment.replies.contains(where: { $0.id == commentId }) {
            comment.replies.removeAll(where: { $0.id == commentId })
            return true
        }
        
        // Check nested replies
        for index in comment.replies.indices {
            var updatedReply = comment.replies[index]
            if findAndDeleteReply(&updatedReply, commentId: commentId) {
                comment.replies[index] = updatedReply
                return true
            }
        }
        
        return false
    }
    
    func reportComment(_ comment: Post.Comment, reason: String) {
        // Implement report logic here
        print("Comment reported: \(comment.id), Reason: \(reason)")
    }
} 