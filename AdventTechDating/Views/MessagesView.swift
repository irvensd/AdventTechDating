import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isFromCurrentUser: Bool
    let timestamp: Date
    let isRead: Bool
}

struct ChatPreview: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let timestamp: Date
    let unreadCount: Int
    let imageUrl: String?
    let isOnline: Bool
}

struct MessagesView: View {
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var selectedChat: ChatPreview?
    @State private var showReportSheet = false
    @State private var showBlockAlert = false
    @State private var reportReason = ""
    @State private var chats: [ChatPreview] = [
        ChatPreview(
            name: "Sarah Johnson",
            lastMessage: "Looking forward to vespers!",
            timestamp: Date().addingTimeInterval(-300),
            unreadCount: 2,
            imageUrl: nil,
            isOnline: true
        ),
        ChatPreview(
            name: "David Miller",
            lastMessage: "Amen to that! 🙏",
            timestamp: Date().addingTimeInterval(-3600),
            unreadCount: 0,
            imageUrl: nil,
            isOnline: false
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search messages", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Messages List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredChats) { chat in
                            NavigationLink {
                                ChatView(chat: chat)
                            } label: {
                                ChatRow(chat: chat)
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            selectedChat = chat
                                            showBlockAlert = true
                                        } label: {
                                            Label("Block", systemImage: "slash.circle")
                                        }
                                        
                                        Button(role: .destructive) {
                                            selectedChat = chat
                                            showReportSheet = true
                                        } label: {
                                            Label("Report", systemImage: "exclamationmark.triangle")
                                        }
                                        .tint(.orange)
                                    }
                            }
                            
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showReportSheet) {
            ReportUserView(user: selectedChat?.name ?? "", reason: $reportReason) { reason in
                handleReport(user: selectedChat?.name ?? "", reason: reason)
            }
        }
        .alert("Block User", isPresented: $showBlockAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Block", role: .destructive) {
                handleBlock(user: selectedChat?.name ?? "")
            }
        } message: {
            Text("Are you sure you want to block \(selectedChat?.name ?? "")? You won't receive any messages from them.")
        }
    }
    
    private var filteredChats: [ChatPreview] {
        if searchText.isEmpty {
            return chats
        }
        return chats.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func handleReport(user: String, reason: String) {
        // TODO: Implement report functionality
        print("Reported \(user) for: \(reason)")
    }
    
    private func handleBlock(user: String) {
        // TODO: Implement block functionality
        print("Blocked user: \(user)")
    }
}

struct ChatRow: View {
    let chat: ChatPreview
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    )
                
                // Online Status Indicator
                if chat.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            // Message Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(timeAgo(from: chat.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.yellow)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    let chat: ChatPreview
    @State private var messageText = ""
    @State private var showOptions = false
    @State private var showReportSheet = false
    @State private var showBlockAlert = false
    @State private var messages: [Message] = [
        Message(content: "Hi there! 👋", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-3600), isRead: true),
        Message(content: "Hello! How are you?", isFromCurrentUser: true, timestamp: Date().addingTimeInterval(-3300), isRead: true),
        Message(content: "Looking forward to vespers!", isFromCurrentUser: false, timestamp: Date().addingTimeInterval(-300), isRead: false)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(messageText.isEmpty ? .gray : .yellow)
                }
            }
            .padding()
            .background(Color.white)
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showBlockAlert = true
                    } label: {
                        Label("Block User", systemImage: "slash.circle")
                    }
                    
                    Button(role: .destructive) {
                        showReportSheet = true
                    } label: {
                        Label("Report User", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showReportSheet) {
            ReportUserView(user: chat.name, reason: .constant("")) { reason in
                // Handle report
                print("Reported \(chat.name) for: \(reason)")
            }
        }
        .alert("Block User", isPresented: $showBlockAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Block", role: .destructive) {
                // Handle block
                print("Blocked user: \(chat.name)")
                dismiss()
            }
        } message: {
            Text("Are you sure you want to block \(chat.name)? You won't receive any messages from them.")
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = Message(
            content: messageText,
            isFromCurrentUser: true,
            timestamp: Date(),
            isRead: false
        )
        
        withAnimation {
            messages.append(newMessage)
            messageText = ""
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser { Spacer() }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .foregroundColor(message.isFromCurrentUser ? .white : .black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        message.isFromCurrentUser ? Color.yellow : Color(.systemGray6)
                    )
                    .cornerRadius(16)
                
                HStack(spacing: 4) {
                    Text(timeString(from: message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if message.isFromCurrentUser {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(message.isRead ? .green : .gray)
                    }
                }
            }
            
            if !message.isFromCurrentUser { Spacer() }
        }
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ReportUserView: View {
    let user: String
    @Binding var reason: String
    let onSubmit: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let reportReasons = [
        "Inappropriate content",
        "Harassment",
        "Spam",
        "Fake profile",
        "Other"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Why are you reporting \(user)?")) {
                    ForEach(reportReasons, id: \.self) { reason in
                        Button(action: {
                            self.reason = reason
                        }) {
                            HStack {
                                Text(reason)
                                Spacer()
                                if self.reason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                }
                
                if reason == "Other" {
                    Section(header: Text("Please provide details")) {
                        TextEditor(text: $reason)
                            .frame(height: 100)
                    }
                }
                
                Section {
                    Button("Submit Report") {
                        onSubmit(reason)
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    MessagesView(selectedTab: .constant(0))
} 