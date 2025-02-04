import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.yellow)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Photo Section
                        VStack(spacing: 8) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 40))
                                )
                            
                            Button("Edit Photo") {
                                // Action
                            }
                            .foregroundColor(.yellow)
                        }
                        .padding(.vertical)
                        
                        // Personal Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "PERSONAL INFORMATION")
                            
                            NavigationLink {
                                EditProfileView()
                            } label: {
                                ProfileRow(title: "Edit Profile")
                            }
                            
                            NavigationLink {
                                InterestsView()
                            } label: {
                                ProfileRow(title: "Interests & Hobbies", icon: "heart.text.square")
                            }
                            
                            NavigationLink {
                                FaithAndValuesView()
                            } label: {
                                ProfileRow(title: "Faith & Values", icon: "heart.circle")
                            }
                        }
                        
                        // Prayer & Spirituality Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "PRAYER & SPIRITUALITY")
                            
                            NavigationLink {
                                PrayerPartnersView()
                            } label: {
                                ProfileRow(title: "Prayer Partners", icon: "hands.sparkles")
                            }
                        }
                        
                        // Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "SETTINGS")
                            
                            NavigationLink {
                                AccountSettingsView()
                            } label: {
                                ProfileRow(title: "Account Settings")
                            }
                            
                            NavigationLink {
                                PrivacySettingsView()
                            } label: {
                                ProfileRow(title: "Privacy")
                            }
                            
                            NavigationLink {
                                SafetySettingsView()
                            } label: {
                                ProfileRow(title: "Safety")
                            }
                        }
                        
                        // Account Actions Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "ACCOUNT ACTIONS")
                            
                            Button(action: { showSignOutAlert = true }) {
                                HStack {
                                    Text("Sign Out")
                                        .foregroundColor(.blue)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: { showDeleteAlert = true }) {
                                HStack {
                                    Text("Delete Account")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGray6))
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    // Handle sign out
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // Handle account deletion
                }
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.footnote)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfileRow: View {
    let title: String
    var icon: String = "chevron.right"
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: icon)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        ProfileView(selectedTab: .constant(4))
    }
} 