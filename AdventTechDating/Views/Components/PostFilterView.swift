import SwiftUI

struct PostFilterView: View {
    @ObservedObject var viewModel: CommunityViewModel
    let community: Community
    
    var body: some View {
        VStack(spacing: 16) {
            // Sort Option
            Picker("Sort by", selection: $viewModel.postSortOption) {
                ForEach(CommunityViewModel.PostSortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Post.PostCategory.allCases, id: \.self) { category in
                        CategoryPill(
                            text: category.rawValue,
                            isSelected: viewModel.selectedCategory == category
                        )
                        .onTapGesture {
                            withAnimation {
                                if viewModel.selectedCategory == category {
                                    viewModel.selectedCategory = nil
                                } else {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Popular Tags
            if !viewModel.popularTags(in: community).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Popular Tags")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.popularTags(in: community), id: \.self) { tag in
                                TagPill(
                                    text: tag,
                                    isSelected: viewModel.selectedTags.contains(tag)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        if viewModel.selectedTags.contains(tag) {
                                            viewModel.selectedTags.remove(tag)
                                        } else {
                                            viewModel.selectedTags.insert(tag)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    PostFilterView(
        viewModel: CommunityViewModel(),
        community: sampleCommunities[0]
    )
} 