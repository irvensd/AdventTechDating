import Foundation
import FirebaseFirestore
import CoreLocation

struct UserProfile: Codable, Identifiable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var birthDate: Date
    var createdAt: Date
    var photoURL: String?
    var bio: String?
    var gender: Gender?
    var lookingFor: Gender?
    var location: GeoPoint?
    var church: String?
    var denomination: String?
    var baptized: Bool?
    var interests: [String]?
    var ministryInterests: [String]?
    var lastActive: Date?
    var isOnline: Bool?
    var profileCompleted: Bool?
    var occupation: String?
    
    enum Gender: String, Codable {
        case male, female
    }
    
    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, birthDate, createdAt, photoURL, bio
        case gender, lookingFor, location, church, denomination, baptized
        case interests, ministryInterests, lastActive, isOnline, profileCompleted
        case occupation
    }
    
    // Add memberwise initializer
    init(id: String,
         firstName: String,
         lastName: String,
         email: String,
         birthDate: Date,
         createdAt: Date,
         photoURL: String? = nil,
         bio: String? = nil,
         gender: Gender? = nil,
         lookingFor: Gender? = nil,
         location: GeoPoint? = nil,
         church: String? = nil,
         denomination: String? = nil,
         baptized: Bool? = nil,
         interests: [String]? = nil,
         ministryInterests: [String]? = nil,
         lastActive: Date? = nil,
         isOnline: Bool? = nil,
         profileCompleted: Bool? = nil,
         occupation: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.birthDate = birthDate
        self.createdAt = createdAt
        self.photoURL = photoURL
        self.bio = bio
        self.gender = gender
        self.lookingFor = lookingFor
        self.location = location
        self.church = church
        self.denomination = denomination
        self.baptized = baptized
        self.interests = interests
        self.ministryInterests = ministryInterests
        self.lastActive = lastActive
        self.isOnline = isOnline
        self.profileCompleted = profileCompleted
        self.occupation = occupation
    }
    
    // Custom encoding for GeoPoint
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Required properties
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(birthDate, forKey: .birthDate)
        try container.encode(createdAt, forKey: .createdAt)
        
        // Optional properties
        try container.encodeIfPresent(photoURL, forKey: .photoURL)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(lookingFor, forKey: .lookingFor)
        try container.encodeIfPresent(church, forKey: .church)
        try container.encodeIfPresent(denomination, forKey: .denomination)
        try container.encodeIfPresent(baptized, forKey: .baptized)
        try container.encodeIfPresent(interests, forKey: .interests)
        try container.encodeIfPresent(ministryInterests, forKey: .ministryInterests)
        try container.encodeIfPresent(lastActive, forKey: .lastActive)
        try container.encodeIfPresent(isOnline, forKey: .isOnline)
        try container.encodeIfPresent(profileCompleted, forKey: .profileCompleted)
        try container.encodeIfPresent(occupation, forKey: .occupation)
        
        // Handle GeoPoint separately
        if let location = location {
            let geoPoint = [
                "latitude": location.latitude,
                "longitude": location.longitude
            ]
            try container.encode(geoPoint, forKey: .location)
        }
    }
    
    // Custom decoding for GeoPoint
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required properties
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        email = try container.decode(String.self, forKey: .email)
        birthDate = try container.decode(Date.self, forKey: .birthDate)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        // Optional properties
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender)
        lookingFor = try container.decodeIfPresent(Gender.self, forKey: .lookingFor)
        church = try container.decodeIfPresent(String.self, forKey: .church)
        denomination = try container.decodeIfPresent(String.self, forKey: .denomination)
        baptized = try container.decodeIfPresent(Bool.self, forKey: .baptized)
        interests = try container.decodeIfPresent([String].self, forKey: .interests)
        ministryInterests = try container.decodeIfPresent([String].self, forKey: .ministryInterests)
        lastActive = try container.decodeIfPresent(Date.self, forKey: .lastActive)
        isOnline = try container.decodeIfPresent(Bool.self, forKey: .isOnline)
        profileCompleted = try container.decodeIfPresent(Bool.self, forKey: .profileCompleted)
        occupation = try container.decodeIfPresent(String.self, forKey: .occupation)
        
        // Handle GeoPoint separately
        if let geoPoint = try container.decodeIfPresent([String: Double].self, forKey: .location) {
            location = GeoPoint(
                latitude: geoPoint["latitude"] ?? 0,
                longitude: geoPoint["longitude"] ?? 0
            )
        } else {
            location = nil
        }
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    // Add distance calculation
    func distance(from userLocation: CLLocation) -> Double {
        guard let location = location else { return 0 }
        let profileLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distanceInMeters = userLocation.distance(from: profileLocation)
        return distanceInMeters * 0.000621371 // Convert meters directly to miles
    }
} 