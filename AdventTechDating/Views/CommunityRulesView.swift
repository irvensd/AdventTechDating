import SwiftUI

struct CommunityRulesView: View {
    @Environment(\.dismiss) private var dismiss
    let rules: [String]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(rules.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rule \(index + 1)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(rules[index])
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Community Rules")
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
} 