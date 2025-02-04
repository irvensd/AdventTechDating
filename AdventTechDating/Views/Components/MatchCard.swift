import SwiftUI

struct MatchCard: View {
    let match: MatchProfile
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Circle()
                .fill(Color.yellow.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.yellow)
                )
            
            // Match Info
            VStack(alignment: .leading, spacing: 4) {
                Text(match.name)
                    .font(.headline)
                
                Text("Matched \(match.timeAgo)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Message Button
            Button(action: {
                // Handle message action
            }) {
                Image(systemName: "message.fill")
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.yellow.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 