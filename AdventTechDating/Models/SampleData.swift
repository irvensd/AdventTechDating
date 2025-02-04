import Foundation
import FirebaseFirestore

struct SampleData {
    static let profiles = [
        // 0-5 miles (Downtown Sacramento)
        UserProfile(
            id: UUID().uuidString,
            firstName: "Sarah",
            lastName: "Johnson",
            email: "sarah.johnson@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -24, to: Date())!,
            createdAt: Date(),
            photoURL: "sarah_1",
            bio: "Social worker focused on helping families in the community. Active in prison ministry and family counseling.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.5816, longitude: -121.4944), // Sacramento downtown
            church: "Sacramento Central SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Family Ministry", "Prison Ministry", "Counseling"],
            ministryInterests: ["Family Ministry", "Prison Ministry", "Community Services"],
            lastActive: Date(),
            isOnline: true,
            profileCompleted: true,
            occupation: "Social Worker"
        ),

        // 8-10 miles (Elk Grove)
        UserProfile(
            id: UUID().uuidString,
            firstName: "Jessica",
            lastName: "Parker",
            email: "jessica.parker@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -27, to: Date())!,
            createdAt: Date(),
            photoURL: "jessica_1",
            bio: "Elementary school teacher who loves working with children's ministry. Passionate about Adventist education.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.4088, longitude: -121.3716), // Elk Grove (~10mi)
            church: "Elk Grove SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Children's Ministry", "Education", "Sabbath School"],
            ministryInterests: ["Teaching", "Youth Programs", "Bible Studies"],
            lastActive: Date(),
            isOnline: true,
            profileCompleted: true,
            occupation: "Teacher"
        ),

        // 15-20 miles (Roseville)
        UserProfile(
            id: UUID().uuidString,
            firstName: "Michelle",
            lastName: "Wong",
            email: "michelle.wong@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
            createdAt: Date(),
            photoURL: "michelle_1",
            bio: "Graduate student in environmental science. Love combining faith with environmental stewardship.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.7521, longitude: -121.2880), // Roseville (~17mi)
            church: "Roseville SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Environmental Ministry", "Campus Ministry", "Health"],
            ministryInterests: ["Creation Care", "Student Outreach", "Health Ministry"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Graduate Student"
        ),

        // 25-30 miles (Auburn)
        UserProfile(
            id: UUID().uuidString,
            firstName: "Rachel",
            lastName: "Martinez",
            email: "rachel.martinez@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -26, to: Date())!,
            createdAt: Date(),
            photoURL: "rachel_1",
            bio: "Tech professional by day, worship leader by weekend. Love using technology for ministry.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.8966, longitude: -121.0768), // Auburn (~28mi)
            church: "Auburn SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Music Ministry", "Technology", "Young Adults"],
            ministryInterests: ["Worship Leading", "Media Ministry", "Tech Evangelism"],
            lastActive: Date(),
            isOnline: true,
            profileCompleted: true,
            occupation: "Software Engineer"
        ),

        // 40-45 miles (Davis)
        UserProfile(
            id: UUID().uuidString,
            firstName: "Emma",
            lastName: "Thompson",
            email: "emma.thompson@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -23, to: Date())!,
            createdAt: Date(),
            photoURL: "emma_1",
            bio: "Medical student with a heart for mission work. Love combining healthcare with ministry.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.5449, longitude: -121.7405), // Davis (~42mi)
            church: "Davis SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Medical Ministry", "Mission Work", "Health Education"],
            ministryInterests: ["Healthcare Outreach", "Mission Trips", "Health Seminars"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Medical Student"
        ),

        // 15 miles - Elk Grove
        UserProfile(
            id: UUID().uuidString,
            firstName: "Jessica",
            lastName: "Parker",
            email: "jessica.parker@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -27, to: Date())!,
            createdAt: Date(),
            photoURL: "jessica_1",
            bio: "Elementary school teacher who loves working with children's ministry. Passionate about Adventist education.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.4088, longitude: -121.3716), // Elk Grove (~10mi)
            church: "Elk Grove SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Children's Ministry", "Education", "Sabbath School"],
            ministryInterests: ["Teaching", "Youth Programs", "Bible Studies"],
            lastActive: Date(),
            isOnline: true,
            profileCompleted: true,
            occupation: "Teacher"
        ),

        // 30 miles - Roseville
        UserProfile(
            id: UUID().uuidString,
            firstName: "Michelle",
            lastName: "Wong",
            email: "michelle.wong@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
            createdAt: Date(),
            photoURL: "michelle_1",
            bio: "Graduate student in environmental science. Love combining faith with environmental stewardship.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.7521, longitude: -121.2880), // Roseville (~17mi)
            church: "Roseville SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Environmental Ministry", "Campus Ministry", "Health"],
            ministryInterests: ["Creation Care", "Student Outreach", "Health Ministry"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Graduate Student"
        ),

        // 45 miles - Folsom
        UserProfile(
            id: UUID().uuidString,
            firstName: "Rachel",
            lastName: "Martinez",
            email: "rachel.martinez@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -26, to: Date())!,
            createdAt: Date(),
            photoURL: "rachel_1",
            bio: "Tech professional by day, worship leader by weekend. Love using technology for ministry.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.6780, longitude: -121.1760), // Folsom (~45mi)
            church: "Auburn SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Music Ministry", "Technology", "Young Adults"],
            ministryInterests: ["Worship Leading", "Media Ministry", "Tech Evangelism"],
            lastActive: Date(),
            isOnline: true,
            profileCompleted: true,
            occupation: "Software Engineer"
        ),

        // 60 miles - Stockton
        UserProfile(
            id: UUID().uuidString,
            firstName: "Emma",
            lastName: "Thompson",
            email: "emma.thompson@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -23, to: Date())!,
            createdAt: Date(),
            photoURL: "emma_1",
            bio: "Medical student with a heart for mission work. Love combining healthcare with ministry.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 37.9577, longitude: -121.2908), // Stockton (~60mi)
            church: "Davis SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Medical Ministry", "Mission Work", "Health Education"],
            ministryInterests: ["Healthcare Outreach", "Mission Trips", "Health Seminars"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Medical Student"
        ),

        // 75 miles - Modesto
        UserProfile(
            id: UUID().uuidString,
            firstName: "Sophia",
            lastName: "Garcia",
            email: "sophia.garcia@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -28, to: Date())!,
            createdAt: Date(),
            photoURL: "sophia_1",
            bio: "Community college student studying business. Passionate about community service and leadership.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 37.6390, longitude: -120.9969), // Modesto (~75mi)
            church: "Modesto SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Community Service", "Leadership", "Business"],
            ministryInterests: ["Community Outreach", "Leadership Development", "Business Management"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Community College Student"
        ),

        // 90 miles - South Lake Tahoe
        UserProfile(
            id: UUID().uuidString,
            firstName: "Olivia",
            lastName: "Chen",
            email: "olivia.chen@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -29, to: Date())!,
            createdAt: Date(),
            photoURL: "olivia_1",
            bio: "Freelance graphic designer and part-time student. Loves creating designs that reflect faith and creativity.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 38.9399, longitude: -119.9772), // South Lake Tahoe (~90mi)
            church: "South Lake Tahoe SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Graphic Design", "Art", "Faith and Creativity"],
            ministryInterests: ["Design", "Art", "Faith and Creativity"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Freelance Graphic Designer"
        ),

        // 100 miles - Reno
        UserProfile(
            id: UUID().uuidString,
            firstName: "Isabella",
            lastName: "Kim",
            email: "isabella.kim@example.com",
            birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!,
            createdAt: Date(),
            photoURL: "isabella_1",
            bio: "Full-time student studying computer science. Passionate about technology and innovation.",
            gender: UserProfile.Gender.female,
            lookingFor: UserProfile.Gender.male,
            location: GeoPoint(latitude: 39.5296, longitude: -119.8138), // Reno (~100mi)
            church: "Reno SDA Church",
            denomination: "Seventh-day Adventist",
            baptized: true,
            interests: ["Computer Science", "Technology", "Innovation"],
            ministryInterests: ["Technology", "Innovation", "Computer Science"],
            lastActive: Date(),
            isOnline: false,
            profileCompleted: true,
            occupation: "Full-time Student"
        )
    ]
} 