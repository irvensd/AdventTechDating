import SwiftUI
import Foundation
import Combine

struct CommentsView: View {
    let post: Post
    @Environment(\.dismiss) private var dismiss
    @State private var newComment = ""
    @State private var isPostingComment = false
    @StateObject private var viewModel: CommentsViewModel
    @State private var showRecoveryAlert = false
    
    init(post: Post, parentViewModel: CommunityViewModel? = nil) {
        self.post = post
        self._viewModel = StateObject(wrappedValue: CommentsViewModel(post: post, parentViewModel: parentViewModel))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Original Post
                PostPreview(post: post)
                    .padding()
                    .background(Color.white)
                
                // Add sort picker
                HStack {
                    CommentSortPicker(selection: $viewModel.sortOption)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Comments List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.sortedComments) { comment in
                            CommentRow(
                                comment: comment,
                                actions: CommentAction(
                                    onReply: viewModel.addReply,
                                    onLike: viewModel.likeComment,
                                    onEdit: viewModel.editComment,
                                    onDelete: viewModel.deleteComment,
                                    onReport: viewModel.reportComment
                                ),
                                depth: 0
                            )
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGray6))
                
                // Comment Input
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $newComment)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: postComment) {
                            if isPostingComment {
                                ProgressView()
                                    .tint(.yellow)
                            } else {
                                Text("Post")
                                    .fontWeight(.medium)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPostingComment)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showRecoveryAlert = true }) {
                            Label("Restore Comments", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Restore Comments", isPresented: $showRecoveryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Restore") {
                    viewModel.restoreFromBackup()
                }
            } message: {
                Text("Would you like to restore comments from the last backup?")
            }
        }
        .onAppear {
            // Refresh comments when view appears
            viewModel.loadComments()
        }
    }
    
    private func postComment() {
        guard !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPostingComment = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let comment = Post.Comment(
                authorId: "currentUser",
                authorName: "Current User",
                content: newComment.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            viewModel.addReply(comment) // Use addReply instead of direct insertion
            isPostingComment = false
            newComment = ""
        }
    }
}

struct PostPreview: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                Text(post.authorName)
                    .font(.headline)
                
                Spacer()
                
                Text(timeAgoString(from: post.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(post.content)
                .font(.body)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Previews
#Preview("Comments View") {
    let previewPost = Post(
        authorId: "user1",
        authorName: "John Doe",
        communityId: UUID(),
        content: "Test post content",
        comments: [
            Post.Comment(
                authorId: "user2",
                authorName: "Jane Smith",
                content: "First comment"
            )
        ]
    )
    
    let previewCommunity = Community(
        name: "Test Community",
        category: "Discussion",
        description: "A test community",
        icon: "star.fill",
        members: 1,
        posts: 0,
        isPrivate: false,
        rules: [],
        admins: ["admin1"]
    )
    
    let previewViewModel = CommunityViewModel(communities: [previewCommunity])
    previewViewModel.addPost(previewPost, to: previewCommunity)
    
    return NavigationStack {
        CommentsView(
            post: previewPost,
            parentViewModel: previewViewModel
        )
    }
} 