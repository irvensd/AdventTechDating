import SwiftUI

struct PrayerPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PrayerPartnersViewModel
    
    @State private var name: String = ""
    @State private var selectedInterests: Set<PrayerPartner.PrayerInterest> = []
    @State private var preferredTime: PrayerPartner.PreferredTime = .flexible
    @State private var prayerFrequency: PrayerPartner.PrayerFrequency = .weekly
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Info
                Section("Basic Information") {
                    TextField("Your Name", text: $name)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .overlay(
                            Group {
                                if bio.isEmpty {
                                    Text("Share a brief introduction...")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 4)
                                }
                            }
                            , alignment: .topLeading
                        )
                }
                
                // Prayer Interests
                Section("Prayer Interests") {
                    ForEach(PrayerPartner.PrayerInterest.allCases, id: \.self) { interest in
                        Toggle(interest.rawValue, isOn: Binding(
                            get: { selectedInterests.contains(interest) },
                            set: { isSelected in
                                if isSelected {
                                    selectedInterests.insert(interest)
                                } else {
                                    selectedInterests.remove(interest)
                                }
                            }
                        ))
                        .tint(.yellow)
                    }
                }
                
                // Availability
                Section("Availability") {
                    Picker("Preferred Prayer Time", selection: $preferredTime) {
                        ForEach(PrayerPartner.PreferredTime.allCases, id: \.self) { time in
                            Text(time.rawValue).tag(time)
                        }
                    }
                    
                    Picker("Prayer Frequency", selection: $prayerFrequency) {
                        ForEach(PrayerPartner.PrayerFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                }
                
                // Guidelines Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Be respectful and supportive", systemImage: "heart.fill")
                        Label("Maintain confidentiality", systemImage: "lock.fill")
                        Label("Commit to regular prayer", systemImage: "clock.fill")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                } header: {
                    Text("GUIDELINES")
                }
            }
            .navigationTitle("Prayer Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: savePreferences) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .bold()
                        }
                    }
                    .disabled(isLoading || !isValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
        }
        .onAppear {
            // Load existing preferences
            if viewModel.isProfileComplete {
                name = viewModel.userProfile.name
                bio = viewModel.userProfile.bio
                selectedInterests = Set(viewModel.userProfile.prayerInterests)
                preferredTime = viewModel.userProfile.preferredTime
                prayerFrequency = viewModel.userProfile.prayerFrequency
            }
        }
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedInterests.isEmpty &&
        !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func savePreferences() {
        isLoading = true
        
        Task {
            do {
                let newProfile = PrayerPartner(
                    id: viewModel.userProfile.id,
                    userId: viewModel.userProfile.userId,
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    prayerInterests: Array(selectedInterests),
                    preferredTime: preferredTime,
                    prayerFrequency: prayerFrequency,
                    bio: bio.trimmingCharacters(in: .whitespacesAndNewlines),
                    isAvailable: true
                )
                
                try await viewModel.updateProfile(newProfile)
                dismiss()
            } catch {
                showError = true
            }
            isLoading = false
        }
    }
} 