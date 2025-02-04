import SwiftUI

struct MatchesView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = MatchesViewModel()
    @State private var selectedFilter = 0
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showPremiumUpgrade = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.black)
                    .padding(.vertical, 20)
                
                Text("Your Matches")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .background(Color.yellow.opacity(0.1))
            
            if premiumManager.isPremiumUser {
                // Show full matches content
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.matches) { match in
                            MatchCard(match: match)
                        }
                    }
                    .padding()
                }
            } else {
                // Show premium upgrade prompt
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Unlock Your Matches")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Upgrade to Premium to see who likes you and more!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showPremiumUpgrade = true
                    }) {
                        Text("Upgrade to Premium")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
        }
    }
}

struct FilterButton: View {
    let title: String
    let count: Int
    
    var body: some View {
        Button(action: {}) {
            Text("\(title)")
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct LockedProfileCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(1, contentMode: .fit)
            
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
                .font(.system(size: 24))
        }
    }
}

#Preview {
    MatchesView(selectedTab: .constant(1))
} 