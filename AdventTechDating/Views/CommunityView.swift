import SwiftUI

struct CommunityView: View {
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var selectedSection = 0 // 0 = Discover, 1 = My Communities
    @State private var showCreateCommunity = false
    @State private var showJoinConfirmation = false
    @State private var selectedCommunity: Community?
    @StateObject private var viewModel = CommunityViewModel()
    
    var filteredCommunities: [Community] {
        let sourceList = selectedSection == 0 ? viewModel.communities : viewModel.myCommunities
        
        if searchText.isEmpty {
            return sourceList
        }
        
        return sourceList.filter { community in
            community.name.localizedCaseInsensitiveContains(searchText) ||
            community.category.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBarView
            sectionToggleView
            
            if filteredCommunities.isEmpty {
                EmptyStateView(selectedSection: selectedSection)
            } else {
                communityListView
            }
        }
        .sheet(isPresented: $showCreateCommunity) {
            CreateCommunityView(isPresented: $showCreateCommunity, onCreate: handleCreateCommunity)
        }
        .sheet(item: $selectedCommunity) { community in
            CommunityDetailView(community: community, viewModel: viewModel)
        }
        .alert("Join Community", isPresented: $showJoinConfirmation, presenting: selectedCommunity) { community in
            Button("Cancel", role: .cancel) { }
            Button("Join") {
                handleJoin(community)
            }
        } message: { community in
            Text("Would you like to join \(community.name)?")
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.yellow)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Community")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: { showCreateCommunity = true }) {
                Image(systemName: "plus")
                    .foregroundColor(.yellow)
                    .font(.title2)
            }
        }
        .padding()
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search communities", text: $searchText)
        }
        .padding(8)
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private var sectionToggleView: some View {
        HStack {
            sectionButton(title: "Discover", section: 0)
            sectionButton(title: "My Communities", section: 1)
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
    }
    
    private func sectionButton(title: String, section: Int) -> some View {
        Button {
            withAnimation {
                selectedSection = section
            }
        } label: {
            Text(title)
                .foregroundColor(selectedSection == section ? .black : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(selectedSection == section ? Color.white : Color.clear)
                .cornerRadius(20)
        }
    }
    
    private var communityListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCommunities) { community in
                    CommunityCard(
                        community: community,
                        isMember: viewModel.myCommunities.contains(where: { $0.id == community.id }),
                        onJoin: { handleJoin(community) },
                        onLeave: { handleLeave(community) },
                        onTap: handleCommunityTap
                    )
                }
            }
            .padding()
        }
    }
    
    private func handleJoin(_ community: Community) {
        withAnimation {
            viewModel.joinCommunity(community)
        }
    }
    
    private func handleLeave(_ community: Community) {
        withAnimation {
            viewModel.leaveCommunity(community)
        }
    }
    
    private func handleCommunityTap(_ community: Community) {
        selectedCommunity = community
    }
    
    private func handleCreateCommunity(_ community: Community) {
        viewModel.createCommunity(community)
    }
}

struct EmptyStateView: View {
    let selectedSection: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedSection == 0 ? "magnifyingglass" : "person.3")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(selectedSection == 0 ? "No communities found" : "You haven't joined any communities yet")
                .font(.headline)
            
            Text(selectedSection == 0 ? "Try adjusting your search" : "Join a community to connect with others")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    CommunityView(selectedTab: .constant(0))
} 