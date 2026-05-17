import Foundation

/// 使用 Open-Meteo 免费 API（无需 API Key）
struct WeatherAPIService: Sendable {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func fetchWeather(for city: String) async throws -> WeatherItem {
        let location = try await geocode(city: city)
        let forecast = try await fetchForecast(
            latitude: location.latitude,
            longitude: location.longitude
        )

        return WeatherItem(
            city: location.name,
            temperature: forecast.temperature,
            humidity: forecast.humidity,
            windSpeed: forecast.windSpeed,
            description: WMOWeatherCode.description(for: forecast.weatherCode)
        )
    }

    private func geocode(city: String) async throws -> GeocodingResult {
        var components = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        components.queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "zh"),
        ]

        let (data, response) = try await session.data(from: components.url!)
        try validateHTTP(response)

        let payload = try decoder.decode(GeocodingResponse.self, from: data)
        guard let first = payload.results?.first else {
            throw WeatherError.cityNotFound(city)
        }
        return first
    }

    private func fetchForecast(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code"),
        ]

        let (data, response) = try await session.data(from: components.url!)
        try validateHTTP(response)

        let payload = try decoder.decode(ForecastResponse.self, from: data)
        guard let current = payload.current else {
            throw WeatherError.invalidResponse
        }
        return current
    }

    private func validateHTTP(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw WeatherError.invalidResponse
        }
    }
}

// MARK: - API Models

private struct GeocodingResponse: Decodable {
    let results: [GeocodingResult]?
}

private struct GeocodingResult: Decodable {
    let name: String
    let latitude: Double
    let longitude: Double
}

private struct ForecastResponse: Decodable {
    let current: CurrentWeather?
}

private struct CurrentWeather: Decodable {
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case humidity = "relative_humidity_2m"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
    }
}

enum WMOWeatherCode {
    static func description(for code: Int) -> String {
        switch code {
        case 0: return "晴朗"
        case 1, 2, 3: return "多云"
        case 45, 48: return "雾"
        case 51, 53, 55: return "毛毛雨"
        case 61, 63, 65: return "雨"
        case 71, 73, 75: return "雪"
        case 80, 81, 82: return "阵雨"
        case 95, 96, 99: return "雷暴"
        default: return "未知"
        }
    }
}
