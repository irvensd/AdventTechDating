import SwiftUI
import FirebaseFirestore

struct PrayerPartnersView: View {
    @StateObject private var viewModel = PrayerPartnersViewModel()
    @State private var showPreferences = false
    @State private var showMatches = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                Text("Prayer Partners")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Prayer Partner Card
                        if viewModel.isProfileComplete {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("YOUR PRAYER PROFILE")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                PrayerProfileCard(profile: viewModel.userProfile)
                                    .onTapGesture {
                                        showPreferences = true
                                    }
                            }
                            .padding(.horizontal)
                            
                            // Find Partners Button
                            Button(action: { showMatches = true }) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                    Text("Find Prayer Partners")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                            }
                            .padding()
                        } else {
                            // Setup Profile Card
                            SetupPrayerProfileCard()
                                .onTapGesture {
                                    showPreferences = true
                                }
                                .padding()
                        }
                        
                        // Active Prayer Partners
                        if !viewModel.activePrayerPartners.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("ACTIVE PRAYER PARTNERS")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                ForEach(viewModel.activePrayerPartners) { partner in
                                    ActivePartnerCard(partner: partner)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPreferences) {
            PrayerPreferencesView(viewModel: viewModel)
        }
        .sheet(isPresented: $showMatches) {
            PrayerMatchesView(viewModel: viewModel)
        }
    }
}

struct SetupPrayerProfileCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 48))
                .foregroundColor(.yellow)
            
            Text("Set Up Prayer Profile")
                .font(.headline)
            
            Text("Create your profile to connect with prayer partners")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ActivePartnerCard: View {
    let partner: PrayerPartner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(partner.name)
                        .font(.headline)
                    Text("Prayer Partner")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: PrayerChatView(partner: partner)) {
                    Image(systemName: "message.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    PrayerPartnersView()
}

struct PrayerProfileCard: View {
    let profile: PrayerPartner
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile Header
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(profile.name)
                        .font(.headline)
                    Text(profile.preferredTime.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            // Prayer Interests
            FlowLayout(spacing: 8) {
                ForEach(profile.prayerInterests, id: \.self) { interest in
                    Text(interest.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
            }
            
            // Prayer Frequency
            HStack {
                Image(systemName: "clock.fill")
                Text("Prays \(profile.prayerFrequency.rawValue)")
                Spacer()
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 