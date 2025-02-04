import Foundation
import SwiftUI

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var communities: [Community]
    @Published var myCommunities: [Community] = []
    @Published var selectedCommunity: Community?
    @Published var isLoading = false
    @Published var error: String?
    @Published var showError = false
    @Published var communityPosts: [UUID: [Post]] = [:]
    @Published var postSortOption: PostSortOption = .newest
    @Published var selectedCategory: Post.PostCategory?
    @Published var searchText = ""
    @Published var selectedTags: Set<String> = []
    
    private let userDefaults = UserDefaults.standard
    private let myCommunityIdsKey = "myCommunityIds"
    private let postsKey = "community_posts"
    
    private var isOffline: Bool {
        !NetworkMonitor.shared.isConnected
    }
    
    init(communities: [Community] = sampleCommunities) {
        self.communities = communities
        loadSavedCommunities()
        loadSavedPosts()
    }
    
    private func loadSavedCommunities() {
        if let savedIds = userDefaults.array(forKey: myCommunityIdsKey) as? [String] {
            myCommunities = communities.filter { community in
                savedIds.contains(community.id.uuidString)
            }
        }
    }
    
    private func saveMyCommunities() {
        let communityIds = myCommunities.map { $0.id.uuidString }
        userDefaults.set(communityIds, forKey: myCommunityIdsKey)
    }
    
    private func loadSavedPosts() {
        if let data = UserDefaults.standard.data(forKey: postsKey),
           let decoded = try? JSONDecoder().decode([UUID: [Post]].self, from: data) {
            communityPosts = decoded
        }
    }
    
    private func savePosts() {
        if let encoded = try? JSONEncoder().encode(communityPosts) {
            UserDefaults.standard.set(encoded, forKey: postsKey)
        }
    }
    
    func joinCommunity(_ community: Community) {
        guard !isMember(of: community) else { return }
        
        // Update the community's member count
        if let index = communities.firstIndex(where: { $0.id == community.id }) {
            var updatedCommunity = communities[index]
            updatedCommunity.members += 1
            communities[index] = updatedCommunity
            myCommunities.append(updatedCommunity)
            
            // Update selected community if it's the one being modified
            if selectedCommunity?.id == community.id {
                selectedCommunity = updatedCommunity
            }
        }
        
        saveMyCommunities()
        objectWillChange.send()
    }
    
    func leaveCommunity(_ community: Community) {
        // Update the community's member count
        if let index = communities.firstIndex(where: { $0.id == community.id }) {
            var updatedCommunity = communities[index]
            updatedCommunity.members -= 1
            communities[index] = updatedCommunity
            myCommunities.removeAll(where: { $0.id == community.id })
            
            // Update selected community if it's the one being modified
            if selectedCommunity?.id == community.id {
                selectedCommunity = updatedCommunity
            }
        }
        
        saveMyCommunities()
        objectWillChange.send()
    }
    
    private func provideFeedback(_ type: FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        switch type {
        case .success:
            generator.notificationOccurred(.success)
        case .error:
            generator.notificationOccurred(.error)
        }
    }
    
    enum FeedbackType {
        case success
        case error
    }
    
    enum CommunityError: LocalizedError {
        case alreadyMember
        case notFound
        case offline
        case networkError
        case serverError
        case rateLimited
        case invalidOperation
        
        var errorDescription: String? {
            switch self {
            case .alreadyMember:
                return "You are already a member of this community"
            case .notFound:
                return "Community not found"
            case .offline:
                return "You are currently offline"
            case .networkError:
                return "Network error. Please try again"
            case .serverError:
                return "Server error. Please try again later"
            case .rateLimited:
                return "Please wait before trying again"
            case .invalidOperation:
                return "This operation is not allowed"
            }
        }
    }
    
    func createCommunity(_ community: Community) {
        communities.append(community)
        myCommunities.append(community)
    }
    
    func isMember(of community: Community) -> Bool {
        myCommunities.contains(where: { $0.id == community.id })
    }
    
    func getPosts(for community: Community) -> [Post] {
        communityPosts[community.id] ?? []
    }
    
    func addPost(_ post: Post, to community: Community) {
        var posts = communityPosts[community.id] ?? []
        posts.insert(post, at: 0)
        communityPosts[community.id] = posts
        objectWillChange.send()
    }
    
    // Get posts for a community
    func posts(for community: Community) -> [Post] {
        let allPosts = communityPosts[community.id] ?? []
        
        return allPosts
            .filter { post in
                // Category filter
                if let category = selectedCategory, post.category != category {
                    return false
                }
                
                // Tags filter
                if !selectedTags.isEmpty && !post.tags.contains(where: { selectedTags.contains($0) }) {
                    return false
                }
                
                // Search text
                if !searchText.isEmpty {
                    return post.content.localizedCaseInsensitiveContains(searchText) ||
                           post.authorName.localizedCaseInsensitiveContains(searchText) ||
                           post.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
                }
                
                return true
            }
            .sorted { post1, post2 in
                switch postSortOption {
                case .newest:
                    return post1.timestamp > post2.timestamp
                case .oldest:
                    return post1.timestamp < post2.timestamp
                case .mostLiked:
                    return post1.likes > post2.likes
                case .mostComments:
                    return post1.comments.count > post2.comments.count
                }
            }
    }
    
    func popularTags(in community: Community) -> [String] {
        let allPosts = communityPosts[community.id] ?? []
        var tagCounts: [String: Int] = [:]
        
        allPosts.forEach { post in
            post.tags.forEach { tag in
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts.sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key }
    }
    
    enum PostSortOption: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case mostLiked = "Most Liked"
        case mostComments = "Most Comments"
    }
    
    func updatePostComments(postId: UUID, newComments: [Post.Comment]) {
        guard let selectedCommunity = selectedCommunity else {
            print("No community selected")
            return
        }
        
        // Update the post in communityPosts directly
        if var posts = communityPosts[selectedCommunity.id] {
            if let postIndex = posts.firstIndex(where: { $0.id == postId }) {
                var updatedPost = posts[postIndex]
                updatedPost.comments = newComments
                posts[postIndex] = updatedPost
                communityPosts[selectedCommunity.id] = posts
                
                // Trigger UI update
                objectWillChange.send()
                
                // Save changes
                savePosts()
            }
        }
    }
    
    // Helper method to safely get posts for a community
    private func getPostsForCommunity(_ community: Community) -> [Post] {
        return communityPosts[community.id] ?? []
    }
    
    // Helper method to safely update a post in a community
    private func updatePost(_ post: Post, in community: Community) {
        var posts = communityPosts[community.id] ?? []
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
            communityPosts[community.id] = posts
            savePosts()
        }
    }
} 