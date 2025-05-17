//
//  ContentView.swift
//  VenaCu
//
//  Created by Charis Georgiou on 5/17/25.
//

import SwiftUI

// Dummy data structure for leg stats
struct LegDailyStats {
    var sedentaryHours: String = "3h 30m"
    var legElevation: String = "1h 15m"
    var standingTime: String = "4h 20m"
    var painLevel: String = "2/10"
}

struct LegIndicators {
    var bloodPressure: Double = 0.75 // Example: 75%
    var bpText: String = "120/80"
    var swelling: Double = 0.5
    var swellingText: String = "Moderate"
    var temperature: Double = 0.3
    var tempText: String = "37.0°C"
}

// View for the circular indicators
struct LegStatusCircle: View {
    var value: Double // 0.0 to 1.0
    var label: String
    var color: Color
    var displayText: String
    let fontSize: CGFloat = 10 // Adjusted for potentially smaller text
    let circleSize: CGFloat = 65 // Slightly smaller circles
    let lineWidth: CGFloat = 7

    var body: some View {
        VStack {
            Text(label)
                .font(.custom("Manrope-Medium", size: fontSize + 1))
                .foregroundColor(.gray)
            ZStack {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.value, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0)) // Start from top
                Text(displayText)
                    .font(.custom("Manrope-Semibold", size: fontSize))
                    .multilineTextAlignment(.center)
            }
            .frame(width: circleSize, height: circleSize)
            .padding(.bottom, 3)
        }
    }
}

// View for each leg section
struct LegCardView: View {
    var legName: String
    @Binding var isShowingCamera: Bool
    var indicators: LegIndicators = LegIndicators()
    var dailyStats: LegDailyStats = LegDailyStats()

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(legName)
                .font(.custom("Manrope-Bold", size: 20))
                .padding(.bottom, 5)

            // First Row: Status Circles
            HStack { 
                // Adding a bit of leading/trailing padding to this HStack if needed for edge spacing
                // For now, relying on the parent VStack's padding and Spacers for distribution.
                LegStatusCircle(value: indicators.bloodPressure, label: "Blood pressure", color: .green, displayText: indicators.bpText)
                Spacer()
                LegStatusCircle(value: indicators.swelling, label: "Swelling", color: .red, displayText: indicators.swellingText)
                Spacer()
                LegStatusCircle(value: indicators.temperature, label: "Temperature", color: .yellow, displayText: indicators.tempText)
            }.padding(.horizontal, 5) // Add slight horizontal padding to the row of circles

            // Second Row: Camera Button and Stats
            HStack(alignment: .top, spacing: 15) { // Changed to .top, removed outer Spacers
                // Camera Button
                Button(action: {
                    isShowingCamera = true
                }) {
                    VStack { // Content for the button
                        Image(systemName: "camera") // Simpler camera icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50) // Adjusted size
                            .foregroundColor(.blue)
                        Text("Upload Photo")
                            .font(.custom("Manrope-Regular", size: 12))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center) // Takes up half space, centers its content
                
                // Daily Stats Column
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Stats")
                        .font(.custom("Manrope-Bold", size: 14))
                        .padding(.bottom, 2)
                    Text("Sedentary: \(dailyStats.sedentaryHours)")
                    Text("Elevation: \(dailyStats.legElevation)")
                    Text("Standing: \(dailyStats.standingTime)")
                    Text("Pain Level: \(dailyStats.painLevel)")
                }
                .font(.custom("Manrope-Regular", size: 11))
                .foregroundColor(Color.secondary.opacity(0.8)) 
                .frame(maxWidth: .infinity, alignment: .center) // Takes up half space, centers the VStack block (text inside is leading)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .cornerRadius(15)
    }
}

struct ContentView: View {
    @State private var isShowingCamera = false
    // Dummy data for now
    let leftLegIndicators = LegIndicators(bloodPressure: 0.7, bpText: "118/78", swelling: 0.3, swellingText: "Mild", temperature: 0.2, tempText: "36.8°C")
    let rightLegIndicators = LegIndicators(bloodPressure: 0.8, bpText: "122/80", swelling: 0.6, swellingText: "Moderate", temperature: 0.4, tempText: "37.1°C")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("VenaCura") // Changed from VenaCu to VenaCura as per mock
                                .font(.custom("Manrope-Bold", size: 30))
                            Text("Welcome back, Jane")
                                .font(.custom("Manrope-Regular", size: 18))
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    }
                    .padding([.horizontal, .top])
                    
                    // Left Leg Card
                    LegCardView(legName: "Left leg", isShowingCamera: $isShowingCamera, indicators: leftLegIndicators)
                        .padding(.horizontal)
                    
                    // Right Leg Card
                    LegCardView(legName: "Right leg", isShowingCamera: $isShowingCamera, indicators: rightLegIndicators) // This will show camera for both, can be individualized later
                        .padding(.horizontal)
                    
                    Spacer() // Pushes content to top
                }
                .padding(.top) // Add some padding at the very top of the scroll view content
            }
            // .navigationTitle("VenaCura") // Title is now in the VStack
            // .navigationBarHidden(true) // If you want to completely hide the navigation bar
            .sheet(isPresented: $isShowingCamera) {
                CameraView() 
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Recommended for fewer console warnings
    }
}

#Preview {
    ContentView()
}
