//
//  UVIndexData.swift
//  date-the-sun
//
//  Created by I Gusti Ngurah Bagus Ferry Mahayudha on 29/05/26.
//

import Foundation

struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let hourly: HourlyWeather
}

struct CurrentWeather: Codable {
    let time: String
    let temperature: Double
    let windSpeed: Double
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let uvIndex: [Double] // Handles the array sequence cleanly
    
    enum CodingKeys: String, CodingKey {
        case time
        case uvIndex = "uv_index"
    }
}

class WeatherService {
    func fetchWeather(latitude: Double = 0.0389,longitude: Double = 46.6753) async throws -> WeatherResponse {
        // Explicitly asks for uv_index in hourly parameters, and localizes time arrays
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,wind_speed_10m&hourly=uv_index&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
