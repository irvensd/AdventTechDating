import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            // Home Tab
            Button(action: { selectedTab = 0 }) {
                TabBarButton(imageName: "flame", title: "Home", isSelected: selectedTab == 0)
            }
            .buttonStyle(BounceButtonStyle())
            
            // Matches Tab
            Button(action: { selectedTab = 1 }) {
                TabBarButton(imageName: "sparkles", title: "Matches", isSelected: selectedTab == 1)
            }
            .buttonStyle(BounceButtonStyle())
            
            // Community Tab
            Button(action: { selectedTab = 2 }) {
                TabBarButton(imageName: "person.3", title: "Community", isSelected: selectedTab == 2)
            }
            .buttonStyle(BounceButtonStyle())
            
            // Messages Tab
            Button(action: { selectedTab = 3 }) {
                TabBarButton(imageName: "message", title: "Messages", isSelected: selectedTab == 3)
            }
            .buttonStyle(BounceButtonStyle())
            
            // Profile Tab
            Button(action: { selectedTab = 4 }) {
                TabBarButton(imageName: "person", title: "Profile", isSelected: selectedTab == 4)
            }
            .buttonStyle(BounceButtonStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: -2)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct TabBarButton: View {
    let imageName: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .yellow : .gray)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(isSelected ? .yellow : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(selectedTab: .constant(0))
    }
} 