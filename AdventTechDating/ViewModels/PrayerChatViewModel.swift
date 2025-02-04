import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine
import Foundation

@MainActor
class PrayerChatViewModel: ObservableObject {
    @Published var messages: [PrayerMessage] = []
    @Published var error: String?
    
    let currentUserId: String
    private let partnerId: String
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init(partnerId: String) {
        self.partnerId = partnerId
        self.currentUserId = Auth.auth().currentUser?.uid ?? ""
        
        setupMessagesListener()
    }
    
    private func setupMessagesListener() {
        listenerRegistration = db.collection("prayerMessages")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.messages = documents.compactMap { document in
                    try? document.data(as: PrayerMessage.self)
                }
            }
    }
    
    func sendMessage(content: String, type: PrayerMessage.MessageType) {
        let message = PrayerMessage(
            id: UUID().uuidString,
            senderId: currentUserId,
            receiverId: partnerId,
            content: content,
            timestamp: Date(),
            type: type,
            isRead: false
        )
        
        Task {
            do {
                try await db.collection("prayerMessages").document(message.id).setData(from: message)
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
} 