import SwiftUI

struct FaithAndValuesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isBaptized") private var isBaptized = false
    @AppStorage("keepsSabbath") private var keepsSabbath = false
    @AppStorage("isVegetarian") private var isVegetarian = false
    @AppStorage("noAlcohol") private var noAlcohol = false
    @AppStorage("missionInterest") private var missionInterest = false
    @AppStorage("churchInvolvement") private var churchInvolvement = "Regular Attendee"
    @AppStorage("ellenWhiteView") private var ellenWhiteView = "Fully Accept"
    @State private var showChurchPicker = false
    @State private var showEllenWhitePicker = false
    @State private var showPremiumAlert = false
    @State private var showPremiumUpgrade = false
    @ObservedObject private var premiumManager = PremiumManager.shared
    
    private let churchInvolvementOptions = [
        "Regular Attendee",
        "Church Officer",
        "Pastor",
        "Occasional Attendee",
        "New Member",
        "Active Member"
    ]
    
    private let ellenWhiteViewOptions = [
        "Fully Accept",
        "Mostly Accept",
        "Still Studying",
        "Uncertain"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Profile")
                    }
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Faith & Values")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
            }
            .padding()
            .background(Color.yellow)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Faith Questions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("BASIC FAITH QUESTIONS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Baptized Seventh-day Adventist", isOn: $isBaptized)
                            ToggleRow(title: "Keep the Sabbath (Friday sunset to Saturday sunset)", isOn: $keepsSabbath)
                            ToggleRow(title: "Practice vegetarian/plant-based diet", isOn: $isVegetarian)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Lifestyle & Beliefs
                    VStack(alignment: .leading, spacing: 16) {
                        Text("LIFESTYLE & BELIEFS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 1) {
                            ToggleRow(title: "Abstain from alcohol", isOn: $noAlcohol, isPremium: true)
                            ToggleRow(title: "Interest in mission work", isOn: $missionInterest, isPremium: true)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Church Life
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CHURCH LIFE")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        SelectionRow(
                            title: "Church Involvement",
                            value: churchInvolvement,
                            isPremium: true,
                            action: { handlePremiumFeature { showChurchPicker = true } }
                        )
                        .sheet(isPresented: $showChurchPicker) {
                            SelectionPickerView(
                                title: "Church Involvement",
                                options: churchInvolvementOptions,
                                selection: $churchInvolvement,
                                isPresented: $showChurchPicker
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Doctrinal Views
                    VStack(alignment: .leading, spacing: 16) {
                        Text("DOCTRINAL VIEWS")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        SelectionRow(
                            title: "View on Ellen White's Writings",
                            value: ellenWhiteView,
                            isPremium: true,
                            action: { handlePremiumFeature { showEllenWhitePicker = true } }
                        )
                        .sheet(isPresented: $showEllenWhitePicker) {
                            SelectionPickerView(
                                title: "View on Ellen White's Writings",
                                options: ellenWhiteViewOptions,
                                selection: $ellenWhiteView,
                                isPresented: $showEllenWhitePicker
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Premium Upgrade Section
                    VStack(spacing: 16) {
                        Text("PREMIUM FEATURES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Unlock all Faith & Values features")
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            
                            Button(action: {
                                showPremiumUpgrade = true
                            }) {
                                Text("Upgrade to Premium")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.yellow)
                                    .cornerRadius(25)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6))
        }
        .navigationBarHidden(true)
        .alert("Premium Feature", isPresented: $showPremiumAlert) {
            Button("Upgrade to Premium") {
                showPremiumAlert = false
                showPremiumUpgrade = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This feature is only available to premium members")
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.spring(), value: showChurchPicker)
        .animation(.spring(), value: showEllenWhitePicker)
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
        }
    }
    
    private func handlePremiumFeature(action: @escaping () -> Void) {
        // TODO: Check if user is premium
        let isPremium = false
        
        if isPremium {
            action()
        } else {
            showPremiumAlert = true
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    var isPremium: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.black)
            
            Spacer()
            
            if isPremium {
                PremiumBadge()
                    .transition(.scale.combined(with: .opacity))
            }
            
            Toggle("", isOn: $isOn.animation(.spring()))
                .tint(.yellow)
                .disabled(isPremium)
        }
        .padding()
        Divider()
    }
}

struct SelectionRow: View {
    let title: String
    let value: String
    var isPremium: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                
                Spacer()
                
                if isPremium {
                    PremiumBadge()
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text(value)
                    .foregroundColor(.yellow)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct SelectionPickerView: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.spring()) {
                            selection = option
                            isPresented = false
                        }
                    }) {
                        HStack {
                            Text(option)
                                .foregroundColor(.black)
                            Spacer()
                            if option == selection {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.yellow)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .transition(.slide)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
        .transition(.move(edge: .bottom))
    }
}

struct PremiumBadge: View {
    var body: some View {
        Text("Premium Feature")
            .font(.caption)
            .foregroundColor(.yellow)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.yellow, lineWidth: 1)
            )
    }
}

#Preview {
    FaithAndValuesView()
} 