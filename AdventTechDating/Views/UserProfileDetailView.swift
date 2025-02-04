import SwiftUI
import FirebaseFirestore
import CoreLocation

struct UserProfileDetailView: View {
    let profile: UserProfile
    @Binding var isPresented: Bool
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Profile Content
                    VStack(spacing: 24) {
                        // Profile Image
                        profileImageView
                        
                        // Basic Info
                        basicInfoSection
                        
                        // Ministry Interests
                        ministryInterestsSection
                        
                        // Faith & Values
                        faithValuesSection
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray6))
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("\(profile.firstName) \(profile.lastName)")
                .font(.system(size: 17, weight: .semibold))
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
    
    private var profileImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.yellow.opacity(0.1))
                .frame(height: 400)
            
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .foregroundColor(.yellow)
        }
        .padding(.top)
    }
    
    private var basicInfoSection: some View {
        InfoSection(title: "ABOUT") {
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "person.fill", text: "\(profile.firstName) \(profile.lastName), \(profile.age)")
                
                if let occupation = profile.occupation {
                    InfoRow(icon: "briefcase.fill", text: occupation)
                }
                
                if let location = profile.location {
                    InfoRow(icon: "location.fill", text: formatLocation(location))
                }
                
                if let bio = profile.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    private var ministryInterestsSection: some View {
        Group {
            if let interests = profile.ministryInterests, !interests.isEmpty {
                InfoSection(title: "MINISTRY INTERESTS") {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(interests), id: \.self) { interest in
                            Text(interest)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.1))
                                .foregroundColor(.black)
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
    }
    
    private var faithValuesSection: some View {
        InfoSection(title: "FAITH & VALUES") {
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "checkmark.seal.fill", text: "Baptized SDA: \(profile.baptized ?? false ? "Yes" : "No")")
                if let church = profile.church {
                    InfoRow(icon: "building.2.fill", text: "Church: \(church)")
                }
                if let denomination = profile.denomination {
                    InfoRow(icon: "cross.fill", text: "Denomination: \(denomination)")
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatLocation(_ location: GeoPoint) -> String {
        let distance = profile.distance(from: locationManager.location)
        return String(format: "%.1f miles away", distance)
    }
}

// Helper Views
struct InfoSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            
            content()
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            Text(text)
                .font(.system(size: 16))
            Spacer()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var origin = bounds.origin
        var maxY: CGFloat = 0
        
        for (index, size) in sizes.enumerated() {
            if origin.x + size.width > bounds.maxX {
                origin.x = bounds.origin.x
                origin.y = maxY + spacing
            }
            
            subviews[index].place(at: origin, proposal: .unspecified)
            origin.x += size.width + spacing
            maxY = max(maxY, origin.y + size.height)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> CGSize {
        var origin = CGPoint.zero
        var maxY: CGFloat = 0
        var maxX: CGFloat = 0
        
        for size in sizes {
            if origin.x + size.width > (proposal.width ?? .infinity) {
                origin.x = 0
                origin.y = maxY + spacing
            }
            
            origin.x += size.width + spacing
            maxY = max(maxY, origin.y + size.height)
            maxX = max(maxX, origin.x)
        }
        
        return CGSize(width: maxX, height: maxY)
    }
} 