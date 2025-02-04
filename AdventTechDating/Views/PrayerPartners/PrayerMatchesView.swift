import SwiftUI

struct PrayerMatchesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PrayerPartnersViewModel
    @State private var selectedPartner: PrayerPartner?
    @State private var showPartnerDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.potentialMatches.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.potentialMatches) { partner in
                                PotentialPartnerCard(partner: partner) {
                                    selectedPartner = partner
                                    showPartnerDetail = true
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Prayer Partners")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.findMatches()
        }
        .sheet(isPresented: $showPartnerDetail) {
            if let partner = selectedPartner {
                PartnerDetailView(partner: partner, viewModel: viewModel)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Matches Found")
                .font(.headline)
            
            Text("Try adjusting your prayer interests to find more potential partners")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                dismiss()
            }) {
                Text("Update Preferences")
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
}

struct PotentialPartnerCard: View {
    let partner: PrayerPartner
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(partner.name)
                            .font(.headline)
                        Text(partner.preferredTime.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                
                // Prayer Interests
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(partner.prayerInterests, id: \.self) { interest in
                            Text(interest.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.1))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                        }
                    }
                }
                
                // Bio Preview
                Text(partner.bio)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 