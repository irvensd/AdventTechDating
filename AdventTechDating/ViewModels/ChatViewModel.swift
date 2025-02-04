import Foundation
import FirebaseFirestore

@MainActor
class ChatViewModel: ObservableObject {
    @Published var conversations: [ChatConversation] = []
    @Published var messages: [ChatMessage] = []
    @Published var error: String?
    
    private let db = Firestore.firestore()
    
    func sendMessage(_ message: ChatMessage, to userId: String) async {
        do {
            try await db.collection("messages").document().setData([
                "senderId": message.senderId,
                "receiverId": userId,
                "content": message.content,
                "timestamp": Timestamp(date: message.timestamp),
                "isRead": false
            ])
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func listenToMessages(with userId: String) {
        db.collection("messages")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    self.error = error?.localizedDescription
                    return
                }
                
                self.messages = documents.compactMap { document in
                    try? document.data(as: ChatMessage.self)
                }
            }
    }
} 