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
    let uvIndex: Double // 👈 Added UV Index
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
        case uvIndex = "uv_index"
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature: [Double]
    let uvIndex: [Double] // 👈 Added Hourly UV Index array
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case uvIndex = "uv_index"
    }
}

class WeatherService {
    enum WeatherError: Error {
        case invalidURL
        case invalidResponse
    }
    
    func fetchWeather(latitude: Double = 48.8566, longitude: Double = 2.3522) async throws -> WeatherResponse {
        // Appended ",uv_index" to both current and hourly URL parameters
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,wind_speed_10m,uv_index&hourly=temperature_2m,uv_index"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherError.invalidResponse
        }
        
        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
