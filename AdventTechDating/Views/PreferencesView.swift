import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("maxDistance") private var maxDistance = 50.0
    @AppStorage("minAge") private var minAge = 18.0
    @AppStorage("maxAge") private var maxAge = 40.0
    @AppStorage("showMen") private var showMen = false
    @AppStorage("showWomen") private var showWomen = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Discovery")) {
                    Toggle("Show Men", isOn: $showMen)
                    Toggle("Show Women", isOn: $showWomen)
                }
                
                Section(header: Text("Distance")) {
                    VStack {
                        Slider(value: $maxDistance, in: 1...100, step: 1)
                        Text("Maximum Distance: \(Int(maxDistance)) miles")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Age Range")) {
                    VStack {
                        Text("Age Range: \(Int(minAge)) - \(Int(maxAge))")
                            .foregroundColor(.gray)
                        CustomRangeSlider(
                            minValue: $minAge,
                            maxValue: $maxAge,
                            bounds: 18...100
                        )
                    }
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CustomRangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: width(in: geometry), height: 4)
                    .offset(x: position(for: minValue, in: geometry))
                
                // Lower Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 4)
                    .offset(x: position(for: minValue, in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateMinValue(value: value, in: geometry)
                            }
                    )
                
                // Upper Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(radius: 4)
                    .offset(x: position(for: maxValue, in: geometry))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                updateMaxValue(value: value, in: geometry)
                            }
                    )
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
    }
    
    private func position(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (value - bounds.lowerBound) / range
        return percentage * (geometry.size.width - 24)
    }
    
    private func width(in geometry: GeometryProxy) -> CGFloat {
        let start = position(for: minValue, in: geometry)
        let end = position(for: maxValue, in: geometry)
        return end - start
    }
    
    private func updateMinValue(value: DragGesture.Value, in geometry: GeometryProxy) {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = value.location.x / (geometry.size.width - 24)
        let newValue = bounds.lowerBound + (range * percentage)
        minValue = min(max(newValue, bounds.lowerBound), maxValue - 1)
    }
    
    private func updateMaxValue(value: DragGesture.Value, in geometry: GeometryProxy) {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = value.location.x / (geometry.size.width - 24)
        let newValue = bounds.lowerBound + (range * percentage)
        maxValue = max(min(newValue, bounds.upperBound), minValue + 1)
    }
}

#Preview {
    PreferencesView()
} 