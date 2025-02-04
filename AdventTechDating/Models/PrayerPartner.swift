struct PrayerPartner: Identifiable, Codable {
    let id: String
    let userId: String
    let name: String
    let prayerInterests: [PrayerInterest]
    let preferredTime: PreferredTime
    let prayerFrequency: PrayerFrequency
    let bio: String
    let isAvailable: Bool
    
    enum PrayerInterest: String, CaseIterable, Codable {
        case health = "Health & Healing"
        case family = "Family & Relationships"
        case spiritual = "Spiritual Growth"
        case career = "Career & Purpose"
        case ministry = "Ministry & Service"
        case addiction = "Recovery & Addiction"
        case mental = "Mental Health"
        case financial = "Financial Breakthrough"
        case missions = "Missions & Outreach"
    }
    
    enum PreferredTime: String, CaseIterable, Codable {
        case morning = "Morning (6AM-12PM)"
        case afternoon = "Afternoon (12PM-5PM)"
        case evening = "Evening (5PM-10PM)"
        case flexible = "Flexible"
    }
    
    enum PrayerFrequency: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case monthly = "Monthly"
    }
} 