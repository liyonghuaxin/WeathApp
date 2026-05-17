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
                        Text("下拉或点击刷新，并发拉取多城市天气")
                    } actions: {
                        Button("加载天气") {
                            Task { await viewModel.loadWeather() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        if viewModel.isLoading {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text(viewModel.items.isEmpty ? "正在加载…" : "正在更新…")
                                    .foregroundStyle(.secondary)
                            }
                            .listRowBackground(Color.clear)
                        }

                        ForEach(viewModel.items) { item in
                            WeatherRowView(item: item)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.items)
                }
            }
            .navigationTitle("多城市天气")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.regular)
                    } else {
                        Button {
                            Task { await viewModel.refresh() }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .accessibilityLabel("刷新")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    if let updated = viewModel.lastUpdated {
                        Text("更新于 \(updated.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                    }
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
        }
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            if viewModel.items.isEmpty, !viewModel.isLoading {
                await viewModel.loadWeather()
            }
        }
    }
}

#Preview {
    ContentView()
}
