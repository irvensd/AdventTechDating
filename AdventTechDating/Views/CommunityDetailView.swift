import SwiftUI

struct CommunityDetailView: View {
    let community: Community
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CommunityViewModel
    @State private var selectedTab = 0
    @State private var showNewPost = false
    @State private var showJoinAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(community.name)
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    if viewModel.isMember(of: community) {
                        Button("Leave Community", role: .destructive) {
                            viewModel.leaveCommunity(community)
                        }
                    }
                    Button("Share Community") { }
                    Button("Report Community", role: .destructive) { }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            
            ScrollView {
                // Community Info Section
                VStack(spacing: 16) {
                    // Stats
                    HStack(spacing: 30) {
                        statsButton(count: community.members, label: "Members")
                        statsButton(count: viewModel.getPosts(for: community).count, label: "Posts")
                    }
                    .padding(.vertical)
                    
                    // Description
                    Text(community.description)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    // Join/Create Post Button
                    if viewModel.isMember(of: community) {
                        Button(action: { showNewPost = true }) {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Create Post")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: { showJoinAlert = true }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Join Community")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Posts Section
                if viewModel.isMember(of: community) {
                    let posts = viewModel.getPosts(for: community)
                    if posts.isEmpty {
                        emptyPostsView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(posts) { post in
                                PostCard(post: post, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showNewPost) {
            CreatePostView(community: community) { post in
                viewModel.addPost(post, to: community)
            }
        }
        .alert("Join Community", isPresented: $showJoinAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Join") {
                viewModel.joinCommunity(community)
            }
        } message: {
            Text("Would you like to join \(community.name)?")
        }
    }
    
    private var emptyPostsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No posts yet")
                .font(.headline)
            
            Text("Be the first to share something!")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
    }
    
    private func statsButton(count: Int, label: String) -> some View {
        VStack {
            Text("\(count)")
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}