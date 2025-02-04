import SwiftUI
import Foundation

// MARK: - Models
struct CommentAction {
    let onReply: (Post.Comment) -> Void
    let onLike: (Post.Comment) -> Void
    let onEdit: (Post.Comment, String) -> Void
    let onDelete: (Post.Comment) -> Void
    let onReport: (Post.Comment, String) -> Void
}

// MARK: - Views
struct CommentRow: View {
    let comment: Post.Comment
    let actions: CommentAction
    let depth: Int
    
    private let maxDepth = 5 // Maximum nesting depth
    @State private var collapsedCommentIds: [String] = UserDefaults.standard.stringArray(forKey: "collapsedComments") ?? []
    @State private var showReplies: Bool = false
    @State private var isReplying = false
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showReportSheet = false
    
    init(comment: Post.Comment, actions: CommentAction, depth: Int = 0) {
        self.comment = comment
        self.actions = actions
        self.depth = depth
        
        // Set initial value for showReplies
        let isCollapsed = UserDefaults.standard.stringArray(forKey: "collapsedComments")?.contains(comment.id.uuidString) ?? false
        _showReplies = State(initialValue: !isCollapsed && !comment.replies.isEmpty)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Depth indicator
            HStack(spacing: 0) {
                ForEach(0..<depth, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .padding(.horizontal, 8)
                }
                
                // Comment content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(comment.authorName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                if comment.isEdited {
                                    Text("(edited)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("·")
                                
                                Text(timeAgoString(from: comment.timestamp))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(comment.content)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Menu {
                            if comment.canEdit {
                                Button(action: { isEditing = true }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                            
                            // Only show delete option for user's own comments
                            if comment.canDelete {
                                Button(role: .destructive, action: { showDeleteAlert = true }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                            Button(action: { showReportSheet = true }) {
                                Label("Report", systemImage: "exclamationmark.triangle")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Actions
                    HStack(spacing: 16) {
                        Button(action: { actions.onLike(comment) }) {
                            HStack(spacing: 4) {
                                Image(systemName: comment.likedBy.contains("currentUser") ? "heart.fill" : "heart")
                                    .foregroundColor(comment.likedBy.contains("currentUser") ? .red : .gray)
                                Text("\(comment.likes)")
                            }
                            .font(.caption)
                            .foregroundColor(comment.likedBy.contains("currentUser") ? .red : .gray)
                        }
                        
                        if !comment.replies.isEmpty {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showReplies.toggle()
                                    updateCollapsedState()
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: showReplies ? "chevron.up" : "chevron.down")
                                    Text("\(comment.replies.count) replies")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                        
                        // Only show reply button if we haven't reached max depth
                        if depth < maxDepth {
                            Button(action: { isReplying = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrowshape.turn.up.left")
                                    Text("Reply")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            
            // Replies section
            if !comment.replies.isEmpty {
                VStack(spacing: 8) {
                    ForEach(comment.replies) { reply in
                        CommentRow(
                            comment: reply,
                            actions: actions,
                            depth: depth + 1
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .scale(scale: 0.95).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.leading, 16)
            }
        }
        .sheet(isPresented: $isReplying) {
            ReplyView(parentComment: comment, onReply: { reply in
                withAnimation(.spring(response: 0.3)) {
                    actions.onReply(reply)
                    showReplies = true
                }
            })
        }
        .sheet(isPresented: $isEditing) {
            EditCommentView(comment: comment, onEdit: actions.onEdit)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportView(comment: comment, onReport: actions.onReport)
        }
        .alert("Delete Comment", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    actions.onDelete(comment)
                }
            }
        } message: {
            Text("Are you sure you want to delete this comment? This action cannot be undone.")
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func updateCollapsedState() {
        var ids = UserDefaults.standard.stringArray(forKey: "collapsedComments") ?? []
        if showReplies {
            ids.removeAll { $0 == comment.id.uuidString }
        } else {
            ids.append(comment.id.uuidString)
        }
        UserDefaults.standard.set(ids, forKey: "collapsedComments")
        collapsedCommentIds = ids
    }
}

struct CommentPreview: View {
    let comment: Post.Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.authorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(timeAgoString(from: comment.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(comment.content)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct EditCommentView: View {
    let comment: Post.Comment
    let onEdit: (Post.Comment, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var editedContent: String
    @State private var isEditing = false
    
    init(comment: Post.Comment, onEdit: @escaping (Post.Comment, String) -> Void) {
        self.comment = comment
        self.onEdit = onEdit
        _editedContent = State(initialValue: comment.content)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextEditor(text: $editedContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Edit Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveEdit()
                        }
                        .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                editedContent == comment.content)
                    }
                }
            }
        }
    }
    
    private func saveEdit() {
        isEditing = true
        onEdit(comment, editedContent)
        dismiss()
    }
}

struct ReportView: View {
    let comment: Post.Comment
    let onReport: (Post.Comment, String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var reportReason = ""
    @State private var isSubmitting = false
    
    private let reportReasons = [
        "Inappropriate content",
        "Harassment",
        "Spam",
        "Off-topic",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Select reason") {
                    ForEach(reportReasons, id: \.self) { reason in
                        Button(action: { reportReason = reason }) {
                            HStack {
                                Text(reason)
                                Spacer()
                                if reportReason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                }
                
                if reportReason == "Other" {
                    Section("Additional details") {
                        TextEditor(text: $reportReason)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Report Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Submit") {
                            submitReport()
                        }
                        .disabled(reportReason.isEmpty)
                    }
                }
            }
        }
    }
    
    private func submitReport() {
        isSubmitting = true
        onReport(comment, reportReason)
        dismiss()
    }
}

struct ReplyView: View {
    let parentComment: Post.Comment
    let onReply: (Post.Comment) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var replyText = ""
    @State private var isPosting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Parent comment preview
                CommentPreview(comment: parentComment)
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                
                // Reply input
                TextEditor(text: $replyText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        Group {
                            if replyText.isEmpty {
                                Text("Write your reply...")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                        }
                        , alignment: .topLeading
                    )
            }
            .padding()
            .navigationTitle("Reply to Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Post") {
                            submitReply()
                        }
                        .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }
    
    private func submitReply() {
        isPosting = true
        
        let reply = Post.Comment(
            authorId: "currentUser",
            authorName: "Current User",
            content: replyText.trimmingCharacters(in: .whitespacesAndNewlines),
            parentId: parentComment.id
        )
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            onReply(reply)
            dismiss()
        }
    }
}

// MARK: - Previews
#Preview("Comment Row") {
    let previewViewModel = CommunityViewModel()
    let previewComment = Post.Comment(
        authorId: "user1",
        authorName: "John Doe",
        content: "This is a test comment",
        replies: []
    )
    
    CommentRow(
        comment: previewComment,
        actions: CommentAction(
            onReply: { _ in },
            onLike: { _ in },
            onEdit: { _, _ in },
            onDelete: { _ in },
            onReport: { _, _ in }
        ),
        depth: 0
    )
    .padding()
}

#Preview("Nested Comments") {
    let previewViewModel = CommunityViewModel()
    let parentComment = Post.Comment(
        authorId: "user1",
        authorName: "John Doe",
        content: "Parent comment",
        replies: [
            Post.Comment(
                authorId: "user2",
                authorName: "Jane Smith",
                content: "Reply to comment",
                parentId: UUID()
            )
        ]
    )
    
    CommentRow(
        comment: parentComment,
        actions: CommentAction(
            onReply: { _ in },
            onLike: { _ in },
            onEdit: { _, _ in },
            onDelete: { _ in },
            onReport: { _, _ in }
        ),
        depth: 0
    )
    .padding()
}

#Preview("Edit Comment") {
    EditCommentView(
        comment: Post.Comment(
            authorId: "user1",
            authorName: "John Doe",
            content: "This is a test comment",
            replies: []
        ),
        onEdit: { _, _ in }
    )
}

#Preview("Report Comment") {
    ReportView(
        comment: Post.Comment(
            authorId: "user1",
            authorName: "John Doe",
            content: "This is a test comment",
            replies: []
        ),
        onReport: { _, _ in }
    )
} 