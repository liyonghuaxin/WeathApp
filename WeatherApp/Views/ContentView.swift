import SwiftUI

struct ContentView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty, !viewModel.isLoading {
                    ContentUnavailableView {
                        Label("暂无天气", systemImage: "cloud.sun")
                    } description: {
                        Text("点击下方按钮并发拉取多城市天气")
                    } actions: {
                        Button("加载天气", action: viewModel.loadWeather)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List(viewModel.items) { item in
                        WeatherRowView(item: item)
                    }
                    .listStyle(.insetGrouped)
                    .overlay {
                        if viewModel.isLoading, viewModel.items.isEmpty {
                            ProgressView("正在并发请求…")
                        }
                    }
                }
            }
            .navigationTitle("多城市天气")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let error = viewModel.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(.ultraThinMaterial)
                }
            }
        }
        .task {
            if viewModel.items.isEmpty {
                viewModel.loadWeather()
            }
        }
    }
}

#Preview {
    ContentView()
}
