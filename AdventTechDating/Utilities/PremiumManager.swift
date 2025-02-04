import SwiftUI

class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @AppStorage("isPremiumUser") private(set) var isPremiumUser = false
    
    private init() {}
    
    func togglePremiumAccess() {
        isPremiumUser.toggle()
    }
    
    func enablePremium() {
        isPremiumUser = true
    }
    
    func disablePremium() {
        isPremiumUser = false
    }
} 