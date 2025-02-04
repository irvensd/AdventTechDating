import SwiftUI
import FirebaseFirestore
import CoreLocation

// Add SwipeDirection enum
enum SwipeDirection {
    case none
    case left
    case right
    case up
}

// Make HomeView public
public struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var currentProfile = 0
    @State private var offset = CGSize.zero
    @State private var showMatchAlert = false
    @State private var matchedProfile: UserProfile?
    @State private var selectedMode = "Dating"
    @State private var cardRotation = 0.0
    @State private var swipeDirection: SwipeDirection = .none
    @State private var showLikeOverlay = false
    @State private var showDislikeOverlay = false
    @State private var hapticFeedback = UINotificationFeedbackGenerator()
    @State private var showPreferences = false
    @State private var showProfileDetail = false
    @State private var selectedProfile: UserProfile?
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showPremiumToggle = false
    @State private var showToast = false
    @State private var starScale: CGFloat = 1.0
    
    // Add a constant for current user's ID (this would normally come from authentication)
    private let currentUserId = UUID().uuidString // Changed to String to match our model
    
    // Update the filteredProfiles computed property
    private var filteredProfiles: [UserProfile] {
        // First filter by gender
        let genderFiltered = SampleData.profiles.filter { $0.gender == .female }
        
        // Then filter out current user
        let finalProfiles = genderFiltered.filter { $0.id != currentUserId }
        
        return finalProfiles.isEmpty ? [] : finalProfiles
    }
    
    // Make body public
    public var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Top Navigation
                    HStack(spacing: 20) {
                        Spacer()
                        
                        Button(action: { showPreferences = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20))
                                .padding(.horizontal, 12)
                        }
                        .sheet(isPresented: $showPreferences) {
                            PreferencesView()
                        }
                        
                        // Premium Toggle Star
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                starScale = 1.3
                                premiumManager.togglePremiumAccess()
                            }
                            
                            // Reset scale
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
                                starScale = 1.0
                            }
                            
                            // Show toast
                            withAnimation {
                                showToast = true
                            }
                            
                            // Hide toast after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                            
                            hapticFeedback.notificationOccurred(.success)
                        }) {
                            Image(systemName: premiumManager.isPremiumUser ? "star.fill" : "star")
                                .font(.system(size: 20))
                                .foregroundColor(.yellow)
                                .scaleEffect(starScale)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Dating/Social Toggle
                    HStack(spacing: 0) {
                        // Dating Tab
                        Text("Dating")
                            .frame(width: 80, height: 32)
                            .background(selectedMode == "Dating" ? Color.yellow : Color.clear)
                            .clipShape(Capsule())
                            .foregroundColor(selectedMode == "Dating" ? .black : .gray)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedMode = "Dating"
                                }
                            }
                        
                        // Social Tab
                        Text("Social")
                            .frame(width: 80, height: 32)
                            .background(selectedMode == "Social" ? Color.yellow : Color.clear)
                            .clipShape(Capsule())
                            .foregroundColor(selectedMode == "Social" ? .black : .gray)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedMode = "Social"
                                }
                            }
                    }
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                    .padding()
                    
                    // Show different content based on selected mode
                    if selectedMode == "Dating" {
                        if filteredProfiles.isEmpty {
                            emptyStateView
                        } else {
                            VStack {
                                cardStack(profiles: filteredProfiles)
                                actionButtons
                            }
                        }
                    } else {
                        // Social view
                        SocialView()
                    }
                }
                
                // Toast Overlay
                if showToast {
                    VStack {
                        Spacer()
                        
                        ToastView(
                            message: premiumManager.isPremiumUser ? "Premium features enabled" : "Premium features disabled",
                            icon: premiumManager.isPremiumUser ? "star.fill" : "star"
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            .background(Color(.systemGray6))
            .alert("It's a Match! 🎉", isPresented: $showMatchAlert) {
                Button("Send Message") {
                    // Handle messaging
                }
                Button("Keep Swiping", role: .cancel) {}
            } message: {
                if let profile = matchedProfile {
                    Text("You and \(profile.firstName) \(profile.lastName) have liked each other!")
                }
            }
            .sheet(isPresented: $showProfileDetail) {
                if let profile = selectedProfile {
                    UserProfileDetailView(profile: profile, isPresented: $showProfileDetail)
                }
            }
            .alert("Beta Premium Access", isPresented: $showPremiumToggle) {
                Button("Enable Premium", role: .none) {
                    premiumManager.enablePremium()
                }
                Button("Disable Premium", role: .destructive) {
                    premiumManager.disablePremium()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Toggle premium access for beta testing")
            }
        }
    }
    
    private func handleSwipe() {
        let threshold: CGFloat = 80
        
        withAnimation(.interpolatingSpring(stiffness: 200, damping: 20)) {
            if offset.width > threshold {
                offset = CGSize(width: UIScreen.main.bounds.width + 100, height: offset.height)
                swipeDirection = .right
                hapticFeedback.notificationOccurred(.success)
                handleLike()
            } else if offset.width < -threshold {
                offset = CGSize(width: -UIScreen.main.bounds.width - 100, height: offset.height)
                swipeDirection = .left
                hapticFeedback.notificationOccurred(.error)
                handleDislike()
            } else {
                offset = .zero
                swipeDirection = .none
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
    }
    
    private func handleLike() {
        withAnimation(.spring(
            response: 0.6,
            dampingFraction: 0.7,
            blendDuration: 0.7
        )) {
            offset = CGSize(width: UIScreen.main.bounds.width + 200, height: 0)
            swipeDirection = .right
        }
        
        checkForMatch()
        
        // Delay the profile transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            nextProfile()
        }
    }
    
    private func handleDislike() {
        withAnimation(.spring(
            response: 0.6,
            dampingFraction: 0.7,
            blendDuration: 0.7
        )) {
            offset = CGSize(width: -UIScreen.main.bounds.width - 200, height: 0)
            swipeDirection = .left
        }
        
        // Delay the profile transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            nextProfile()
        }
    }
    
    private func handleSuperLike() {
        offset = CGSize(width: 0, height: -500)
        checkForMatch()
        nextProfile()
    }
    
    private func nextProfile() {
        let previousOffset = offset
        
        // Reset offset first
        offset = .zero
        swipeDirection = .none
        
        withAnimation(.easeOut(duration: 0.1)) {
            if currentProfile < filteredProfiles.count - 1 {
                currentProfile += 1
            } else {
                // Show empty state or reset to beginning
                currentProfile = 0
            }
        }
    }
    
    private func checkForMatch() {
        // Simulate a match with 20% probability
        if Double.random(in: 0...1) < 0.2 {
            matchedProfile = SampleData.profiles[currentProfile]
            showMatchAlert = true
        }
    }
    
    private func handleSwipeEnd(translation: CGSize, velocity: CGFloat) {
        let threshold: CGFloat = 100 // Increased threshold
        let velocityThreshold: CGFloat = 800 // Increased velocity threshold
        
        if translation.width > threshold || velocity > velocityThreshold {
            offset = CGSize(width: UIScreen.main.bounds.width + 200, height: translation.height + velocity * 0.2)
            swipeDirection = .right
            hapticFeedback.notificationOccurred(.success)
            handleLike()
        } else if translation.width < -threshold || velocity < -velocityThreshold {
            offset = CGSize(width: -UIScreen.main.bounds.width - 200, height: translation.height + velocity * 0.2)
            swipeDirection = .left
            hapticFeedback.notificationOccurred(.error)
            handleDislike()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = .zero
                swipeDirection = .none
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
    
    private func cardStack(profiles: [UserProfile]) -> some View {
        ZStack {
            ForEach(profiles.indices.prefix(5), id: \.self) { index in
                let reversedIndex = profiles.count - 1 - index
                if reversedIndex >= currentProfile && reversedIndex < profiles.count {
                    ProfileCard(
                        profile: profiles[reversedIndex],
                        offset: reversedIndex == currentProfile ? $offset : .constant(.zero),
                        swipeDirection: swipeDirection,
                        onSwipe: { direction in
                            handleSwipe(direction: direction)
                            currentProfile += 1
                        },
                        onProfileTap: { profile in
                            selectedProfile = profile
                            showProfileDetail = true
                        }
                    )
                    .zIndex(Double(profiles.count - reversedIndex))
                }
            }
        }
    }
    
    private func handleSwipe(direction: SwipeDirection) {
        switch direction {
        case .right:
            handleLike()
        case .left:
            handleDislike()
        case .up:
            handleSuperLike()
        case .none:
            break
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No Profiles Available")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Check back later for new matches")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
    
    private var actionButtons: some View {
        VStack {
            Spacer()
            HStack(spacing: 24) {
                dislikeButton
                superLikeButton
                likeButton
            }
            .padding(.bottom, 24)
            .padding(.horizontal)
        }
        .background(Color.clear)
    }
    
    private var dislikeButton: some View {
        Button(action: { 
            hapticFeedback.notificationOccurred(.error)
            withAnimation { handleDislike() }
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 68, height: 68)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.red.opacity(0.8))
                )
        }
    }
    
    private var superLikeButton: some View {
        Button(action: { 
            hapticFeedback.notificationOccurred(.warning)
            handleSuperLike()
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    Image(systemName: "star.fill")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(.yellow)
                )
        }
    }
    
    private var likeButton: some View {
        Button(action: { 
            hapticFeedback.notificationOccurred(.success)
            withAnimation { handleLike() }
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 68, height: 68)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .overlay(
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.green.opacity(0.8))
                )
        }
    }
    
    // Update profile card to use locationManager correctly
    private func profileCard(profile: UserProfile) -> some View {
        ZStack {
            // Main Card with gradient overlay
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .frame(width: UIScreen.main.bounds.width - 32)
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                .overlay(
                    // Profile Image
                    VStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                            .foregroundColor(.yellow.opacity(0.9))
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                )
                .overlay(
                    // Gradient overlay for better text visibility
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .black.opacity(0.1),
                            .black.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(24)
                )
            
            // Info Card with improved typography and spacing
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                // Name and Age - More prominent
                HStack(alignment: .firstTextBaseline) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(profile.age)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    if let location = profile.location {
                        Text(String(format: "%.0f mi", profile.distance(from: locationManager.location)))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Occupation with icon
                if let occupation = profile.occupation {
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 14))
                        Text(occupation)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                
                // Bio with improved readability
                if let bio = profile.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
                
                // Interests with modern design
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let interests = profile.ministryInterests {
                            ForEach(Array(interests.prefix(3)), id: \.self) { interest in
                                Text(interest)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height * 0.6)
        }
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .animation(
            .spring(
                response: 0.6,
                dampingFraction: 0.7,
                blendDuration: 0.7
            ),
            value: offset
        )
        .onTapGesture {
            selectedProfile = profile
            showProfileDetail = true
        }
    }
}

struct ProfileCard: View {
    let profile: UserProfile
    @Binding var offset: CGSize
    let swipeDirection: SwipeDirection
    @StateObject private var locationManager = LocationManager()
    let hapticFeedback = UINotificationFeedbackGenerator()
    let onSwipe: (SwipeDirection) -> Void
    let onProfileTap: (UserProfile) -> Void
    
    var body: some View {
        ZStack {
            // Main Card with gradient overlay
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .frame(width: UIScreen.main.bounds.width - 32)
                .frame(height: UIScreen.main.bounds.height * 0.6)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                .overlay(
                    // Profile Image
                    VStack {
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                            .foregroundColor(.yellow.opacity(0.9))
                            .padding(.top, 40)
                        
                        Spacer()
                    }
                )
                .overlay(
                    // Gradient overlay for better text visibility
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .black.opacity(0.1),
                            .black.opacity(0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(24)
                )
            
            // Info Card with improved typography and spacing
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                // Name and Age - More prominent
                HStack(alignment: .firstTextBaseline) {
                    Text("\(profile.firstName) \(profile.lastName)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(profile.age)")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    if let location = profile.location {
                        Text(String(format: "%.0f mi", profile.distance(from: locationManager.location)))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Occupation with icon
                if let occupation = profile.occupation {
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 14))
                        Text(occupation)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                
                // Bio with improved readability
                if let bio = profile.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .padding(.top, 4)
                }
                
                // Interests with modern design
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        if let interests = profile.ministryInterests {
                            ForEach(Array(interests.prefix(3)), id: \.self) { interest in
                                Text(interest)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height * 0.6)
        }
        .offset(offset)
        .rotationEffect(.degrees(Double(offset.width / 20)))
        .animation(
            .spring(
                response: 0.6,
                dampingFraction: 0.7,
                blendDuration: 0.7
            ),
            value: offset
        )
        .gesture(makeDragGesture())
        .onTapGesture {
            onProfileTap(profile)
        }
    }
    
    private func makeDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                offset = gesture.translation
                hapticFeedback.prepare()
            }
            .onEnded { value in
                let translation = value.translation
                let velocity = value.predictedEndLocation.x - value.location.x
                
                withAnimation(.spring(
                    response: 0.6,
                    dampingFraction: 0.7,
                    blendDuration: 0.7
                )) {
                    handleSwipeEnd(translation: translation, velocity: velocity)
                }
            }
    }
    
    private func handleSwipeEnd(translation: CGSize, velocity: CGFloat) {
        let threshold: CGFloat = 80
        
        if translation.width > threshold || velocity > 800 {
            offset = CGSize(width: 500, height: translation.height)
            onSwipe(.right)
        } else if translation.width < -threshold || velocity < -800 {
            offset = CGSize(width: -500, height: translation.height)
            onSwipe(.left)
        } else if translation.height < -threshold || velocity < -800 {
            offset = CGSize(width: translation.width, height: -500)
            onSwipe(.up)
        } else {
            offset = .zero
        }
    }
}

// Helper view for faith tags
struct FaithTag: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.yellow)
            Text(text)
                .font(.subheadline)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
    }
}

// Add a basic SocialView
struct SocialView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Find Friends")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Connect with other Adventists for friendship and fellowship")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Add social features here
            // ...
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
} 