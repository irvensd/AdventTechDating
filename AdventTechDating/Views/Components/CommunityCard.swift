import SwiftUI

struct CommunityCard: View {
    let community: Community
    let isMember: Bool
    let onJoin: () -> Void
    let onLeave: () -> Void
    let onTap: (Community) -> Void
    @State private var isLoading = false
    @State private var showLeaveConfirmation = false
    @State private var scale: CGFloat = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: community.icon)
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(community.name)
                        .font(.headline)
                    Text(community.category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .tint(.yellow)
                } else if isMember {
                    Menu {
                        Button("Leave Community", role: .destructive) {
                            showLeaveConfirmation = true
                        }
                    } label: {
                        HStack {
                            Text("Member")
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    }
                } else {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            onJoin()
                        }
                    } label: {
                        Text("Join")
                            .foregroundColor(.yellow)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Text(community.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "person.2")
                Text("\(community.members) members")
                Spacer()
                Image(systemName: "message")
                Text("\(community.posts) posts")
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .scaleEffect(scale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.95
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scale = 1
                }
            }
            onTap(community)
        }
        .alert("Leave Community", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                withAnimation {
                    onLeave()
                }
            }
        } message: {
            Text("Are you sure you want to leave \(community.name)?")
        }
    }
}

#Preview {
    CommunityCard(
        community: sampleCommunities[0],
        isMember: true,
        onJoin: {},
        onLeave: {},
        onTap: { _ in }
    )
} 