import SwiftUI

struct CreateCommunityView: View {
    @Binding var isPresented: Bool
    let onCreate: (Community) -> Void
    
    @State private var name = ""
    @State private var category = Community.categories[0]
    @State private var description = ""
    @State private var icon = "person.2.fill"
    @State private var isPrivate = false
    @State private var rules: [String] = ["Be respectful", "No spam"]
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let icons = [
        "person.2.fill", "book.fill", "hands.sparkles.fill", "heart.fill",
        "music.note", "leaf.fill", "cross.fill", "globe"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Community Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(Community.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    HStack {
                        Text("Icon")
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(icons, id: \.self) { iconName in
                                    Image(systemName: iconName)
                                        .font(.title2)
                                        .foregroundColor(icon == iconName ? .yellow : .gray)
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(icon == iconName ? .yellow.opacity(0.2) : .clear)
                                        )
                                        .onTapGesture {
                                            icon = iconName
                                        }
                                }
                            }
                        }
                    }
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section {
                    Toggle("Private Community", isOn: $isPrivate)
                } footer: {
                    Text("Private communities require approval to join")
                }
                
                Section("Community Rules") {
                    ForEach($rules, id: \.self) { $rule in
                        TextField("Rule", text: $rule)
                    }
                    
                    Button("Add Rule") {
                        rules.append("")
                    }
                }
            }
            .navigationTitle("Create Community")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createCommunity()
                    }
                    .fontWeight(.medium)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createCommunity() {
        // Validate inputs
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a community name"
            showError = true
            return
        }
        
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a community description"
            showError = true
            return
        }
        
        // Create new community
        let community = Community(
            name: name,
            category: category,
            description: description,
            icon: icon,
            members: 1,
            posts: 0,
            isPrivate: isPrivate,
            rules: rules.filter { !$0.isEmpty },
            admins: ["Current User"] // Replace with actual user
        )
        
        onCreate(community)
        isPresented = false
    }
}

#Preview {
    CreateCommunityView(isPresented: .constant(false)) { _ in }
} 