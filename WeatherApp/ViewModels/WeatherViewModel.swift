import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class WeatherViewModel {
    private(set) var items: [WeatherItem] = []
    private(set) var isLoading = false
    private(set) var lastError: String?
    private(set) var lastUpdated: Date?

    private let apiService = WeatherAPIService()
    private let defaultCities = ["北京", "上海", "东京", "纽约", "伦敦", "巴黎"]

    func loadWeather() async {
        await refresh()
    }

    func refresh() async {
        guard !isLoading else { return }
        await performRefresh(cities: nil)
    }

    private func performRefresh(cities: [String]?) async {
        let targets = cities ?? defaultCities
        isLoading = true
        lastError = nil

        let service = apiService
        var fetched: [WeatherItem] = []
        var errors: [String] = []

        await withTaskGroup(of: Result<WeatherItem, Error>.self) { group in
            for city in targets {
                group.addTask {
                    do {
                        let item = try await service.fetchWeather(for: city)
                        return .success(item)
                    } catch {
                        return .failure(error)
                    }
                }
            }

            for await result in group {
                switch result {
                case .success(let item):
                    fetched.append(item)
                case .failure(let error):
                    errors.append(error.localizedDescription)
                }
            }
        }

        if !errors.isEmpty, fetched.isEmpty {
            lastError = errors.joined(separator: "\n")
        } else if !errors.isEmpty {
            lastError = "部分城市加载失败：\(errors.prefix(2).joined(separator: "；"))"
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            items = fetched.sorted { $0.city < $1.city }
            if !fetched.isEmpty {
                lastUpdated = Date()
            }
        }
        isLoading = false
    }
}
