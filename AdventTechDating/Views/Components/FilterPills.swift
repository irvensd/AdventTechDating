import SwiftUI

struct CategoryPill: View {
    let text: String
    let isSelected: Bool
    let icon: String?
    
    init(text: String, isSelected: Bool, icon: String? = nil) {
        self.text = text
        self.isSelected = isSelected
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption)
            }
            Text(text)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.yellow : Color(uiColor: .systemGray6))
        .foregroundColor(isSelected ? .black : .gray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 1)
        )
    }
}

struct TagPill: View {
    let text: String
    let isSelected: Bool
    let count: Int?
    
    init(text: String, isSelected: Bool, count: Int? = nil) {
        self.text = text
        self.isSelected = isSelected
        self.count = count
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
            if let count = count {
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.yellow.opacity(0.2) : Color(uiColor: .systemGray6))
        .foregroundColor(isSelected ? .black : .gray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 1)
        )
    }
}

#Preview("Category Pills") {
    HStack {
        CategoryPill(text: "All", isSelected: true)
        CategoryPill(text: "Prayer", isSelected: false, icon: "hands.sparkles")
        CategoryPill(text: "Bible Study", isSelected: false, icon: "book")
    }
    .padding()
}

#Preview("Tag Pills") {
    HStack {
        TagPill(text: "Prayer", isSelected: true, count: 12)
        TagPill(text: "Bible", isSelected: false, count: 8)
        TagPill(text: "Youth", isSelected: false, count: 5)
    }
    .padding()
} 