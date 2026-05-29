//
//  UVBadgeView.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 29/05/26.
//

import SwiftUI

struct UVBadgeView: View {
    
    @State private var weather: WeatherResponse?
    @State private var errorMessage: String?
    @State private var isLoading = true
    
    private let weatherService = WeatherService()
    private var currentUVData: (value: Double, label: String) {
        // 1. Ensure weather is loaded
        guard let hourly = weather?.hourly else {
            return (0.0, "Unknown")
        }
        
        // 2. Safe bounds check: make sure currentHour exists inside the array indices
        let hour = Calendar.current.component(.hour, from: Date())
        guard hourly.uvIndex.indices.contains(hour) else {
            // Fallback to the first item or a default if index is out of bounds
            let fallbackUV = hourly.uvIndex.first ?? 0.0
            return (fallbackUV, uvExposureLabel(fallbackUV))
        }
        
        let uvValue = hourly.uvIndex[hour]
        return (uvValue, uvExposureLabel(uvValue))
    }

    // Helper to dynamically get the EPA UV standard text classification
    private func uvExposureLabel(_ uv: Double) -> String {
        switch uv {
        case 0..<3:   return "Low"
        case 3..<8:   return "Moderate"
        default:       return "high"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Sun Icon (SF Symbols)
            Image(systemName: "sun.max")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.95, green: 0.82, blue: 0.29)) // Custom gold/yellow
            
            // Styled Text Group
            Text("\(Text("UV \(String(format: "%.0f", currentUVData.value)) ").fontWeight(.bold).foregroundColor(Color(red: 0.95, green: 0.82, blue: 0.29)))\(currentUVData.label)")
                .fontWeight(.regular)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color(red: 0.93, green: 0.53, blue: 0.18)) // Main orange background
        )
        .overlay(
            Capsule()
                .stroke(Color(red: 0.70, green: 0.35, blue: 0.08), lineWidth: 1.5) // Darker orange border
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 3) // Soft floating shadow
        .task {
                await loadWeatherData()
            }
    }
    
    private func loadWeatherData() async {
        do {
            self.weather = try await weatherService.fetchWeather()
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}


#Preview {
    UVBadgeView()
}
