import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 1
    @ObservedObject private var premiumManager = PremiumManager.shared
    
    private let plans = [
        PremiumPlan(duration: "1 Month", price: "$29.99", savings: ""),
        PremiumPlan(duration: "6 Months", price: "$19.99/mo", savings: "Save 33%"),
        PremiumPlan(duration: "12 Months", price: "$14.99/mo", savings: "Save 50%")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Premium")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Premium Features
                    VStack(spacing: 16) {
                        Text("PREMIUM FEATURES")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 12) {
                            FeatureRow(icon: "eye.fill", text: "See who likes you")
                            FeatureRow(icon: "message.fill", text: "Priority messaging")
                            FeatureRow(icon: "slider.horizontal.3", text: "Advanced filters")
                            FeatureRow(icon: "heart.fill", text: "Unlimited likes")
                            FeatureRow(icon: "arrow.clockwise", text: "Rewind last swipe")
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Subscription Plans
                    VStack(spacing: 16) {
                        Text("SELECT PLAN")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        
                        ForEach(plans.indices, id: \.self) { index in
                            PlanCard(
                                plan: plans[index],
                                isSelected: selectedPlan == index,
                                action: { selectedPlan = index }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            
            // Subscribe Button
            Button(action: {
                premiumManager.enablePremium()
                dismiss()
            }) {
                Text("Subscribe Now")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .cornerRadius(25)
            }
            .padding()
        }
    }
}

struct PremiumPlan {
    let duration: String
    let price: String
    let savings: String
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            Text(text)
                .foregroundColor(.black)
            Spacer()
        }
    }
}

struct PlanCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.duration)
                        .font(.headline)
                    Text(plan.price)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if !plan.savings.isEmpty {
                    Text(plan.savings)
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.yellow, lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(isSelected ? Color.yellow.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    PremiumUpgradeView()
} 