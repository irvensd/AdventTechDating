import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var age = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var selectedPhotos: [UIImage] = []
    @State private var showImagePicker = false
    @State private var homeChurch = ""
    @State private var occupation = ""
    @State private var churchLocation = ""
    @State private var roleInChurch = ""
    @State private var keepChurchInfoPrivate = false
    @State private var relationshipIntention = "Still Deciding"
    @State private var showIntentionPicker = false
    @State private var showDatePicker = false
    @State private var memberSinceDate = Date()
    
    private let maxPhotos = 6
    
    private let relationshipIntentions = [
        "Still Deciding",
        "Marriage",
        "Dating with Purpose",
        "Friendship First",
        "Long-term Relationship"
    ]
    
    var formattedMemberSince: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: memberSinceDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Navigation Bar - Updated to match Bumble style
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text("Edit Profile")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Spacer()
                    
                    Button("Save") {
                        saveProfile()
                    }
                    .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.top, 60) // Adjust for safe area
                .padding(.bottom, 10)
                .background(
                    Color.yellow
                        .edgesIgnoringSafeArea(.top)
                )
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.black.opacity(0.2))
                        .offset(y: 35),
                    alignment: .bottom
                )
                
                // Photos Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("PHOTOS")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(0..<6) { index in
                            PhotoCell(index: index, selectedPhotos: $selectedPhotos)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Verify Profile Section
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Verify Your Profile")
                        .font(.subheadline)
                    Spacer()
                    Button("Verify Now") {
                        // Handle verification
                    }
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                
                // Basic Information Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("BASIC INFORMATION")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 1) {
                        ProfileTextField(title: "First Name", text: $firstName)
                        ProfileTextField(title: "Last Name", text: $lastName)
                        ProfileTextField(title: "Age", text: $age)
                            .keyboardType(.numberPad)
                        ProfileTextField(title: "Location", text: $location)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // About Me Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("ABOUT ME")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack {
                        Text("Bio")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        TextEditor(text: $bio)
                            .frame(height: 100)
                            .padding(.horizontal)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Faith & Work Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("FAITH & WORK")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 1) {
                        ProfileTextField(title: "Home Church", text: $homeChurch)
                        ProfileTextField(title: "Occupation", text: $occupation)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Relationship Intentions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("RELATIONSHIP INTENTIONS")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Looking for")
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: { showIntentionPicker = true }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.yellow)
                                Text(relationshipIntention)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .sheet(isPresented: $showIntentionPicker) {
                    IntentionPickerView(
                        selectedIntention: $relationshipIntention,
                        intentions: relationshipIntentions,
                        isPresented: $showIntentionPicker
                    )
                }
                
                // Church Information Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("CHURCH INFORMATION")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    VStack(spacing: 1) {
                        ProfileTextField(title: "Home Church", text: $homeChurch)
                        ProfileTextField(title: "Church Location", text: $churchLocation)
                        ProfileTextField(title: "Your Role (Optional)", text: $roleInChurch)
                        
                        // Member Since
                        Button(action: { showDatePicker = true }) {
                            HStack {
                                Text("Member Since")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(formattedMemberSince)
                                    .foregroundColor(.black)
                            }
                            .padding()
                        }
                        Divider()
                        
                        // Privacy Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle("Keep Church Info Private", isOn: $keepChurchInfoPrivate)
                                .tint(.yellow)
                            
                            Text("Your church information helps connect you with local believers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePickerView(
                        selectedDate: $memberSinceDate,
                        isPresented: $showDatePicker
                    )
                }
                
                // Add some bottom padding
                Color.clear.frame(height: 40)
            }
        }
        .background(Color(uiColor: .systemGray6))
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
    }
    
    private func saveProfile() {
        // Simply save and dismiss without validation
        dismiss()
    }
}

struct PhotoCell: View {
    let index: Int
    @Binding var selectedPhotos: [UIImage]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemGray5))
                .aspectRatio(1, contentMode: .fit)
            
            if index < selectedPhotos.count {
                Image(uiImage: selectedPhotos[index])
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(title, text: $text)
                .font(.system(size: 16))
                .padding()
                .background(Color.white)
        }
        Divider()
    }
}

// Helper Views
struct IntentionPickerView: View {
    @Binding var selectedIntention: String
    let intentions: [String]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(intentions, id: \.self) { intention in
                    Button(action: {
                        selectedIntention = intention
                        isPresented = false
                    }) {
                        HStack {
                            Text(intention)
                            Spacer()
                            if intention == selectedIntention {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .foregroundColor(.black)
                }
            }
            .navigationTitle("Looking For")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Member Since",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView()
    }
} 