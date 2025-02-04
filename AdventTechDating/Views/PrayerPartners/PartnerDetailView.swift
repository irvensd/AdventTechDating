import SwiftUI
import FirebaseFirestore

struct PartnerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let partner: PrayerPartner
    @ObservedObject var viewModel: PrayerPartnersViewModel
    @State private var showRequestSheet = false
    @State private var requestMessage = ""
    @State private var isSending = false
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                    
                    Text(partner.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Bio Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("ABOUT")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Text(partner.bio)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Prayer Interests
                VStack(alignment: .leading, spacing: 12) {
                    Text("PRAYER INTERESTS")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(partner.prayerInterests, id: \.self) { interest in
                            Text(interest.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.1))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Availability
                VStack(alignment: .leading, spacing: 12) {
                    Text("AVAILABILITY")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label(partner.preferredTime.rawValue, systemImage: "clock")
                        Label("Prays \(partner.prayerFrequency.rawValue)", systemImage: "calendar")
                    }
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Connect Button
                Button(action: { showRequestSheet = true }) {
                    if isSending {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Connect as Prayer Partners")
                            .fontWeight(.medium)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .foregroundColor(.white)
                .cornerRadius(25)
                .disabled(isSending)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRequestSheet) {
            NavigationView {
                Form {
                    Section {
                        TextEditor(text: $requestMessage)
                            .frame(height: 100)
                            .overlay(
                                Group {
                                    if requestMessage.isEmpty {
                                        Text("Share why you'd like to connect as prayer partners...")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                    }
                                }
                                , alignment: .topLeading
                            )
                    } header: {
                        Text("CONNECTION REQUEST")
                    } footer: {
                        Text("Your message will be sent to \(partner.name)")
                    }
                }
                .navigationTitle("Prayer Request")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showRequestSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Send") {
                            sendRequest()
                        }
                        .disabled(requestMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
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
    
    private func sendRequest() {
        isSending = true
        showRequestSheet = false
        
        Task {
            do {
                try await viewModel.sendPrayerRequest(
                    to: partner,
                    message: requestMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                dismiss()
            } catch {
                showError = true
            }
            isSending = false
        }
    }
} 