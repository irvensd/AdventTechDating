import SwiftUI

struct SafetySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBlockedUsers = false
    @State private var showReportedUsers = false
    
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
                
                Text("Safety")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
            }
            .padding()
            .background(Color.yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Safety Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SAFETY FEATURES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Photo Verification", isOn: .constant(true))
                            ToggleRow(title: "Two-Factor Authentication", isOn: .constant(true))
                            ToggleRow(title: "Location Services", isOn: .constant(true))
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Blocked & Reported
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BLOCKED & REPORTED")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            Button(action: { showBlockedUsers = true }) {
                                HStack {
                                    Text("Blocked Users")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                            
                            Button(action: { showReportedUsers = true }) {
                                HStack {
                                    Text("Reported Users")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Help & Support
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HELP & SUPPORT")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            Button(action: {}) {
                                HStack {
                                    Text("Safety Guidelines")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Text("Contact Support")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Text("Emergency Resources")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                        }
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
    }
} 