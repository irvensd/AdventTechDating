import SwiftUI

struct InterestsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showProfileIn") private var showProfileIn = "Dating Only"
    
    // Add loading and error states
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSaveSuccess = false
    
    // Ministry Interests
    @AppStorage("sabbathSchool") private var sabbathSchool = false
    @AppStorage("youthMinistry") private var youthMinistry = false
    @AppStorage("musicMinistry") private var musicMinistry = false
    @AppStorage("pathfinders") private var pathfinders = false
    @AppStorage("healthMinistry") private var healthMinistry = false
    @AppStorage("bibleStudies") private var bibleStudies = false
    @AppStorage("communityService") private var communityService = false
    
    // Basic Hobbies
    @AppStorage("reading") private var reading = false
    @AppStorage("natureWalks") private var natureWalks = false
    @AppStorage("photography") private var photography = false
    @AppStorage("cooking") private var cooking = false
    
    // Music Preferences
    @AppStorage("hymns") private var hymns = false
    @AppStorage("contemporaryChristian") private var contemporaryChristian = false
    @AppStorage("gospel") private var gospel = false
    @AppStorage("classical") private var classical = false
    @AppStorage("acapella") private var acapella = false
    @AppStorage("christianRock") private var christianRock = false
    @AppStorage("instrumental") private var instrumental = false
    
    // Outreach Interests
    @AppStorage("localEvangelism") private var localEvangelism = false
    @AppStorage("internationalMissions") private var internationalMissions = false
    @AppStorage("healthOutreach") private var healthOutreach = false
    @AppStorage("literatureDistribution") private var literatureDistribution = false
    @AppStorage("prisonMinistry") private var prisonMinistry = false
    @AppStorage("onlineMinistry") private var onlineMinistry = false
    @AppStorage("childrensMinistry") private var childrensMinistry = false
    
    // Church Activities
    @AppStorage("campMeeting") private var campMeeting = false
    @AppStorage("vespers") private var vespers = false
    @AppStorage("potluck") private var potluck = false
    @AppStorage("smallGroups") private var smallGroups = false
    
    // Health & Lifestyle
    @AppStorage("plantBased") private var plantBased = false
    @AppStorage("exercise") private var exercise = false
    @AppStorage("camping") private var camping = false
    @AppStorage("gardening") private var gardening = false
    @AppStorage("healthyLiving") private var healthyLiving = false
    
    // Additional Ministry Interests
    @AppStorage("prophecyStudies") private var prophecyStudies = false
    @AppStorage("youthCamp") private var youthCamp = false
    @AppStorage("adventistEducation") private var adventistEducation = false
    @AppStorage("hospitalMinistry") private var hospitalMinistry = false
    
    // Additional Music
    @AppStorage("adventistHeritage") private var adventistHeritage = false
    @AppStorage("choirMember") private var choirMember = false
    @AppStorage("musicianInstrument") private var musicianInstrument = false
    
    // Spiritual Growth
    @AppStorage("morningDevotion") private var morningDevotion = false
    @AppStorage("sabbathPreparation") private var sabbathPreparation = false
    @AppStorage("familyWorship") private var familyWorship = false
    @AppStorage("bibleJournaling") private var bibleJournaling = false
    
    // Lifestyle Interests
    @AppStorage("healthAndFitness") private var healthAndFitness = false
    @AppStorage("naturalRemedies") private var naturalRemedies = false
    @AppStorage("environmentalCare") private var environmentalCare = false
    @AppStorage("simpleLiving") private var simpleLiving = false
    @AppStorage("homesteading") private var homesteading = false
    @AppStorage("plantBasedCooking") private var plantBasedCooking = false
    @AppStorage("outdoorActivities") private var outdoorActivities = false
    
    // Future Goals
    @AppStorage("startingFamily") private var startingFamily = false
    @AppStorage("missionService") private var missionService = false
    @AppStorage("ministryLeadership") private var ministryLeadership = false
    @AppStorage("healthMinistryGoal") private var healthMinistryGoal = false
    @AppStorage("education") private var education = false
    @AppStorage("churchPlanting") private var churchPlanting = false
    @AppStorage("businessProfessional") private var businessProfessional = false
    
    // Add state for premium sheet
    @State private var showPremiumUpgrade = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar with loading state
            HStack {
                Button(action: { handleDismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Profile")
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Interests")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                if isSaving {
                    ProgressView()
                        .tint(.yellow)
                } else {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Visibility
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PROFILE VISIBILITY")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        SelectionRow(
                            title: "Show Profile In",
                            value: showProfileIn,
                            action: { /* Handle selection */ }
                        )
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Ministry Interests
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MINISTRY INTERESTS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Sabbath School", isOn: $sabbathSchool)
                            ToggleRow(title: "Youth Ministry", isOn: $youthMinistry)
                            ToggleRow(title: "Music Ministry", isOn: $musicMinistry)
                            ToggleRow(title: "Pathfinders", isOn: $pathfinders)
                            ToggleRow(title: "Health Ministry", isOn: $healthMinistry)
                            ToggleRow(title: "Bible Studies", isOn: $bibleStudies)
                            ToggleRow(title: "Community Service", isOn: $communityService, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Basic Hobbies
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BASIC HOBBIES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Reading", isOn: $reading)
                            ToggleRow(title: "Nature Walks", isOn: $natureWalks)
                            ToggleRow(title: "Photography", isOn: $photography)
                            ToggleRow(title: "Cooking", isOn: $cooking)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Music Preferences
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MUSIC PREFERENCES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Hymns", isOn: $hymns)
                            ToggleRow(title: "Contemporary Christian", isOn: $contemporaryChristian)
                            ToggleRow(title: "Gospel", isOn: $gospel)
                            ToggleRow(title: "Classical", isOn: $classical, isPremium: true)
                            ToggleRow(title: "Acapella", isOn: $acapella, isPremium: true)
                            ToggleRow(title: "Christian Rock", isOn: $christianRock, isPremium: true)
                            ToggleRow(title: "Instrumental", isOn: $instrumental, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Outreach Interests
                    VStack(alignment: .leading, spacing: 16) {
                        Text("OUTREACH INTERESTS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Local Evangelism", isOn: $localEvangelism)
                            ToggleRow(title: "International Missions", isOn: $internationalMissions)
                            ToggleRow(title: "Health Outreach", isOn: $healthOutreach)
                            ToggleRow(title: "Literature Distribution", isOn: $literatureDistribution)
                            ToggleRow(title: "Prison Ministry", isOn: $prisonMinistry, isPremium: true)
                            ToggleRow(title: "Online Ministry", isOn: $onlineMinistry, isPremium: true)
                            ToggleRow(title: "Children's Ministry", isOn: $childrensMinistry, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Church Activities
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CHURCH ACTIVITIES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Camp Meeting", isOn: $campMeeting)
                            ToggleRow(title: "Friday Vespers", isOn: $vespers)
                            ToggleRow(title: "Sabbath Potluck", isOn: $potluck)
                            ToggleRow(title: "Small Groups", isOn: $smallGroups)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Health & Lifestyle
                    VStack(alignment: .leading, spacing: 16) {
                        Text("HEALTH & LIFESTYLE")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Plant-Based Living", isOn: $plantBased)
                            ToggleRow(title: "Exercise & Fitness", isOn: $exercise)
                            ToggleRow(title: "Camping & Nature", isOn: $camping)
                            ToggleRow(title: "Gardening", isOn: $gardening)
                            ToggleRow(title: "Health Ministry", isOn: $healthyLiving, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Spiritual Growth
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SPIRITUAL GROWTH")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Morning Devotion", isOn: $morningDevotion)
                            ToggleRow(title: "Sabbath Preparation", isOn: $sabbathPreparation)
                            ToggleRow(title: "Family Worship", isOn: $familyWorship)
                            ToggleRow(title: "Bible Journaling", isOn: $bibleJournaling, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Additional Ministry
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ADDITIONAL MINISTRY")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Prophecy Studies", isOn: $prophecyStudies)
                            ToggleRow(title: "Youth Camp Leadership", isOn: $youthCamp)
                            ToggleRow(title: "Adventist Education", isOn: $adventistEducation)
                            ToggleRow(title: "Hospital Ministry", isOn: $hospitalMinistry, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Musical Talents
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MUSICAL TALENTS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Adventist Heritage Music", isOn: $adventistHeritage)
                            ToggleRow(title: "Choir Member", isOn: $choirMember)
                            ToggleRow(title: "Musical Instrument", isOn: $musicianInstrument, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Lifestyle Interests
                    VStack(alignment: .leading, spacing: 16) {
                        Text("LIFESTYLE INTERESTS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Health & Fitness", isOn: $healthAndFitness)
                            ToggleRow(title: "Natural Remedies", isOn: $naturalRemedies)
                            ToggleRow(title: "Environmental Care", isOn: $environmentalCare)
                            ToggleRow(title: "Simple Living", isOn: $simpleLiving)
                            ToggleRow(title: "Homesteading", isOn: $homesteading, isPremium: true)
                            ToggleRow(title: "Plant-Based Cooking", isOn: $plantBasedCooking, isPremium: true)
                            ToggleRow(title: "Outdoor Activities", isOn: $outdoorActivities, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Future Goals
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FUTURE GOALS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Starting a Family", isOn: $startingFamily)
                            ToggleRow(title: "Mission Service", isOn: $missionService)
                            ToggleRow(title: "Ministry Leadership", isOn: $ministryLeadership, isPremium: true)
                            ToggleRow(title: "Health Ministry", isOn: $healthMinistryGoal, isPremium: true)
                            ToggleRow(title: "Education", isOn: $education)
                            ToggleRow(title: "Church Planting", isOn: $churchPlanting, isPremium: true)
                            ToggleRow(title: "Business/Professional", isOn: $businessProfessional, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
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
                                Text("Unlock all interest categories")
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
        .overlay {
            if showSaveSuccess {
                SaveSuccessOverlay()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .disabled(isSaving)
        .animation(.spring(), value: isSaving)
        .animation(.spring(), value: showSaveSuccess)
    }
    
    private func handleDismiss() {
        if hasUnsavedChanges() {
            // Show confirmation dialog
            // This is a placeholder - implement actual change detection
            dismiss()
        } else {
            dismiss()
        }
    }
    
    private func hasUnsavedChanges() -> Bool {
        // Implement change detection logic
        return false
    }
    
    private func validateSelections() -> Bool {
        // Ensure at least one interest is selected in each required category
        let hasMinistryInterest = sabbathSchool || youthMinistry || musicMinistry || 
                                 pathfinders || healthMinistry || bibleStudies
        
        let hasBasicHobby = reading || natureWalks || photography || cooking
        
        if !hasMinistryInterest {
            errorMessage = "Please select at least one ministry interest"
            showError = true
            return false
        }
        
        if !hasBasicHobby {
            errorMessage = "Please select at least one basic hobby"
            showError = true
            return false
        }
        
        return true
    }
    
    private func saveChanges() {
        guard validateSelections() else { return }
        
        isSaving = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // Save all preferences
                // This would typically be an API call
                
                // Show success feedback
                withAnimation {
                    showSaveSuccess = true
                }
                
                // Dismiss after showing success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } catch {
                errorMessage = "Failed to save changes. Please try again."
                showError = true
            }
            
            isSaving = false
        }
    }
}

// Success overlay view
struct SaveSuccessOverlay: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Changes Saved!")
                .font(.headline)
                .padding(.top, 8)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 8)
    }
}

#Preview {
    InterestsView()
} 