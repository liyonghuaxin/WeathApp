import Foundation

struct WeatherItem: Identifiable, Sendable, Equatable {
    let id: String
    let city: String
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let description: String
    let fetchedAt: Date

    init(
        city: String,
        temperature: Double,
        humidity: Int,
        windSpeed: Double,
        description: String,
        fetchedAt: Date = .now
    ) {
        self.id = city
        self.city = city
        self.temperature = temperature
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.description = description
        self.fetchedAt = fetchedAt
    }
}

enum WeatherError: LocalizedError, Sendable {
    case cityNotFound(String)
    case invalidResponse
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .cityNotFound(let city):
            return "找不到城市：\(city)"
        case .invalidResponse:
            return "天气数据格式无效"
        case .network(let error):
            return error.localizedDescription
        }
    }
}
