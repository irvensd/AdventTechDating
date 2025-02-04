import SwiftUI
import UIKit

struct PostCard: View {
    @ObservedObject var viewModel: CommunityViewModel
    let post: Post
    @State private var showComments = false
    @State private var isLiked: Bool
    @State private var likesCount: Int
    
    init(post: Post, viewModel: CommunityViewModel) {
        self.post = post
        self.viewModel = viewModel
        _isLiked = State(initialValue: post.isLiked)
        _likesCount = State(initialValue: post.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Info
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(post.authorName)
                        .font(.headline)
                    Text(timeAgoString(from: post.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if post.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.yellow)
                }
                
                Menu {
                    Button("Share Post") { }
                    Button("Report Post", role: .destructive) { }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Content
            Text(post.content)
                .font(.body)
            
            // Actions
            HStack(spacing: 20) {
                Button(action: toggleLike) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likesCount)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showComments = true }) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("\(post.comments.count)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showComments) {
            CommentsView(post: post, parentViewModel: viewModel)
        }
    }
    
    private func toggleLike() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isLiked.toggle()
            likesCount += isLiked ? 1 : -1
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
} 