import SwiftUI

struct CommunityMembersView: View {
    @Environment(\.dismiss) private var dismiss
    let community: Community
    @State private var searchText = ""
    @State private var selectedRole: MemberRole = .all
    
    enum MemberRole: String, CaseIterable {
        case all = "All"
        case admin = "Admins"
        case moderator = "Moderators"
        case member = "Members"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 8) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search members", text: $searchText)
                    }
                    .padding(8)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                    
                    // Role Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MemberRole.allCases, id: \.self) { role in
                                RoleFilterButton(role: role, isSelected: selectedRole == role) {
                                    selectedRole = role
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.white)
                
                // Members List
                List {
                    ForEach(filteredMembers, id: \.id) { member in
                        MemberRow(member: member)
                    }
                }
            }
            .navigationTitle("Members")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var filteredMembers: [CommunityMember] {
        var members = sampleMembers
        
        if !searchText.isEmpty {
            members = members.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if selectedRole != .all {
            members = members.filter { member in
                switch selectedRole {
                case .admin: return member.role == .admin
                case .moderator: return member.role == .moderator
                case .member: return member.role == .member
                case .all: return true
                }
            }
        }
        
        return members
    }
}

struct RoleFilterButton: View {
    let role: CommunityMembersView.MemberRole
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(role.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.yellow : Color(uiColor: .systemGray6))
                .foregroundColor(isSelected ? .black : .gray)
                .cornerRadius(16)
        }
    }
}

struct MemberRow: View {
    let member: CommunityMember
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.yellow)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                Text(member.role.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if member.isOnline {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
        }
        .contextMenu {
            if member.role != .admin {
                Button("Message") { }
                Button("View Profile") { }
                if member.role == .member {
                    Button("Make Moderator") { }
                }
                Button("Remove from Community", role: .destructive) { }
            }
        }
    }
}

// Models
struct CommunityMember: Identifiable {
    let id = UUID()
    let name: String
    var role: Role
    var isOnline: Bool
    var joinDate: Date
    
    enum Role: String {
        case admin = "Admin"
        case moderator = "Moderator"
        case member = "Member"
    }
}

// Sample Data
let sampleMembers = [
    CommunityMember(name: "Sarah Johnson", role: .admin, isOnline: true, joinDate: Date().addingTimeInterval(-7776000)),
    CommunityMember(name: "David Miller", role: .moderator, isOnline: false, joinDate: Date().addingTimeInterval(-5184000)),
    CommunityMember(name: "Rachel Chen", role: .member, isOnline: true, joinDate: Date().addingTimeInterval(-2592000))
] 