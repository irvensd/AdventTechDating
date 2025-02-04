import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    private init() {
        // Ensure Firebase is only configured once
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        #if DEBUG
        // Optional: Enable local emulator for testing
        // let settings = Firestore.firestore().settings
        // settings.host = "localhost:8080"
        // settings.isPersistenceEnabled = false
        // settings.isSSLEnabled = false
        // Firestore.firestore().settings = settings
        #endif
    }
} 