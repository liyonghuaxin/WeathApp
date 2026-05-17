import SwiftUI

struct WeatherRowView: View {
    let item: WeatherItem

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.city)
                    .font(.headline)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(item.temperature, specifier: "%.1f")°")
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .contentTransition(.numericText())
                Text("湿度 \(item.humidity)% · 风速 \(item.windSpeed, specifier: "%.0f") km/h")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
