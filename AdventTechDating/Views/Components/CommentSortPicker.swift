import SwiftUI

struct CommentSortPicker: View {
    @Binding var selection: Post.Comment.SortOption
    
    var body: some View {
        Menu {
            ForEach(Post.Comment.SortOption.allCases, id: \.self) { option in
                Button {
                    withAnimation {
                        selection = option
                    }
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "arrow.up.arrow.down")
                Text("Sort by: \(selection.rawValue)")
                    .foregroundColor(.gray)
            }
            .font(.subheadline)
        }
    }
} 