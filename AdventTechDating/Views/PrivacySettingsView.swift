import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profileVisibility") private var profileVisibility = true
    @AppStorage("showDistance") private var showDistance = true
    @AppStorage("showAge") private var showAge = true
    @AppStorage("showLastActive") private var showLastActive = true
    @AppStorage("showReadReceipts") private var showReadReceipts = true
    @State private var showPremiumUpgrade = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Profile")
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Privacy")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
            }
            .padding()
            .background(Color.yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Privacy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PROFILE PRIVACY")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Profile Visibility", isOn: $profileVisibility)
                            ToggleRow(title: "Show Distance", isOn: $showDistance)
                            ToggleRow(title: "Show Age", isOn: $showAge)
                            ToggleRow(title: "Show Last Active", isOn: $showLastActive)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Messaging Privacy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MESSAGING PRIVACY")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Read Receipts", isOn: $showReadReceipts, isPremium: true)
                            ToggleRow(title: "Message Preview", isOn: .constant(true))
                            ToggleRow(title: "Media Auto-Download", isOn: .constant(true))
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Data Privacy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DATA PRIVACY")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        Button(action: {}) {
                            HStack {
                                Text("Download My Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Premium Upgrade Section
                    VStack(spacing: 16) {
                        Text("PREMIUM FEATURES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Unlock all privacy features")
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            
                            Button(action: {
                                showPremiumUpgrade = true
                            }) {
                                Text("Upgrade to Premium")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.yellow)
                                    .cornerRadius(25)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
        }
    }
} 