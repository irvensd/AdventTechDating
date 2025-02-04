import SwiftUI

struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("email") private var email = ""
    @AppStorage("phoneNumber") private var phoneNumber = ""
    @State private var showChangePassword = false
    @State private var showEmailVerification = false
    @State private var showPhoneVerification = false
    
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
                
                Text("Account Settings")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
            }
            .padding()
            .background(Color.yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Account Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ACCOUNT INFORMATION")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ProfileTextField(title: "Email", text: $email)
                            ProfileTextField(title: "Phone Number", text: $phoneNumber)
                            
                            Button(action: { showChangePassword = true }) {
                                HStack {
                                    Text("Change Password")
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
                    
                    // Verification
                    VStack(alignment: .leading, spacing: 16) {
                        Text("VERIFICATION")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            Button(action: { showEmailVerification = true }) {
                                HStack {
                                    Text("Verify Email")
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                            
                            Button(action: { showPhoneVerification = true }) {
                                HStack {
                                    Text("Verify Phone Number")
                                    Spacer()
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                                .foregroundColor(.black)
                                .padding()
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Notifications
                    VStack(alignment: .leading, spacing: 16) {
                        Text("NOTIFICATIONS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Push Notifications", isOn: .constant(true))
                            ToggleRow(title: "Email Notifications", isOn: .constant(true))
                            ToggleRow(title: "Match Alerts", isOn: .constant(true))
                            ToggleRow(title: "Message Notifications", isOn: .constant(true))
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