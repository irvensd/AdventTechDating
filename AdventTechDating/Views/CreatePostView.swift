import SwiftUI

struct CreatePostView: View {
    let community: Community
    let onPost: (Post) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var postContent = ""
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Community Info
                HStack {
                    Image(systemName: community.icon)
                        .foregroundColor(.yellow)
                    Text("Posting in \(community.name)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top)
                
                // Post Content
                TextEditor(text: $postContent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Post")
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
                            createPost()
                        }
                        .disabled(postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createPost() {
        guard !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isPosting = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let post = Post(
                authorId: "currentUser",
                authorName: "Current User",
                communityId: community.id,
                content: postContent,
                timestamp: Date(),
                likes: 0,
                comments: [],
                isLiked: false,
                isPinned: false
            )
            
            onPost(post)
            dismiss()
        }
    }
} 