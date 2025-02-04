import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var showDebugMenu = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                
                MatchesView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Matches")
                    }
                    .tag(1)
                
                CommunityView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Community")
                    }
                    .tag(2)
                
                MessagesView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Messages")
                    }
                    .tag(3)
                
                ProfileView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .accentColor(.yellow)
            
            #if DEBUG
            Button(action: { showDebugMenu = true }) {
                Image(systemName: "ladybug")
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 100) // Move above tab bar
            .sheet(isPresented: $showDebugMenu) {
                DebugMenuView()
            }
            #endif
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var showSignOut = false
    
    // Add any content-specific view model logic here
}

#if DEBUG
struct DebugMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section("Authentication") {
                    Button("Force Logout") {
                        try? authViewModel.signOut()
                        dismiss()
                    }
                    
                    Button("Clear User Data") {
                        authViewModel.userSession = nil
                        authViewModel.currentUser = nil
                        dismiss()
                    }
                }
                
                Section("User Session") {
                    if let user = authViewModel.userSession {
                        Text("User ID: \(user.uid)")
                        Text("Email: \(user.email ?? "None")")
                        Text("Verified: \(user.isEmailVerified ? "Yes" : "No")")
                    } else {
                        Text("No active session")
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
#endif 
