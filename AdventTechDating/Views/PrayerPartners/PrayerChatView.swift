import SwiftUI
import FirebaseFirestore

struct PrayerChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PrayerChatViewModel
    @State private var messageText = ""
    @State private var showMessageTypes = false
    @State private var selectedType: PrayerMessage.MessageType = .text
    
    let partner: PrayerPartner
    
    init(partner: PrayerPartner) {
        self.partner = partner
        _viewModel = StateObject(wrappedValue: PrayerChatViewModel(partnerId: partner.id))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text(partner.name)
                        .font(.headline)
                    Text("Prayer Partner")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: { showMessageTypes = true }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color.white)
            
            // Messages
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        PrayerMessageBubble(message: message, isFromCurrentUser: message.senderId == viewModel.currentUserId)
                    }
                }
                .padding()
            }
            
            // Input Area
            VStack(spacing: 8) {
                if selectedType != .text {
                    HStack {
                        Text(selectedType.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        
                        Spacer()
                        
                        Button(action: { selectedType = .text }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(messageText.isEmpty ? .gray : .yellow)
                    }
                }
                .padding()
            }
            .background(Color.white)
        }
        .sheet(isPresented: $showMessageTypes) {
            MessageTypeSheet(selectedType: $selectedType, isPresented: $showMessageTypes)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        viewModel.sendMessage(content: messageText, type: selectedType)
        messageText = ""
        selectedType = .text
    }
}

struct PrayerMessageBubble: View {
    let message: PrayerMessage
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message Type Icon
                if message.type != .text {
                    HStack {
                        Image(systemName: iconForType(message.type))
                        Text(message.type.rawValue.capitalized)
                    }
                    .font(.caption)
                    .foregroundColor(isFromCurrentUser ? .white : .yellow)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(isFromCurrentUser ? Color.yellow : Color(.systemGray6))
                    .foregroundColor(isFromCurrentUser ? .white : .primary)
                    .cornerRadius(16)
            }
            
            if !isFromCurrentUser { Spacer() }
        }
    }
    
    private func iconForType(_ type: PrayerMessage.MessageType) -> String {
        switch type {
        case .text: return "text.bubble"
        case .prayer: return "hands.sparkles"
        case .scripture: return "book"
        case .praise: return "heart"
        }
    }
}

struct MessageTypeSheet: View {
    @Binding var selectedType: PrayerMessage.MessageType
    @Binding var isPresented: Bool
    
    let types: [(PrayerMessage.MessageType, String, String)] = [
        (.prayer, "Prayer Request", "hands.sparkles"),
        (.scripture, "Share Scripture", "book"),
        (.praise, "Praise Report", "heart")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(types, id: \.0) { type, title, icon in
                    Button(action: {
                        selectedType = type
                        isPresented = false
                    }) {
                        Label(title, systemImage: icon)
                    }
                }
            }
            .navigationTitle("Message Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    PrayerChatView(partner: PrayerPartner(
        id: "preview",
        userId: "preview",
        name: "Preview Partner",
        prayerInterests: [.spiritual, .family],
        preferredTime: .morning,
        prayerFrequency: .daily,
        bio: "Preview bio",
        isAvailable: true
    ))
} 