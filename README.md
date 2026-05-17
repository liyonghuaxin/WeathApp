# WeatherApp

一款使用 SwiftUI 编写的 iOS 天气示例应用，采用常见的 **ViewModel 集中状态** 架构，演示 **async/await 网络请求**、**Task / TaskGroup 并发** 与 **@MainActor**。

## 功能

- 并发请求多个城市当前天气（默认：北京、上海、东京、纽约、伦敦、巴黎）
- 列表展示温度、湿度、风速与天气描述（WMO 天气码转中文）
- 工具栏刷新按钮；加载中显示 `ProgressView`，完成后恢复刷新按钮
- **下拉刷新**（`.refreshable`）与空态「加载天气」按钮
- 列表内加载提示（首次「正在加载…」、已有数据时「正在更新…」）
- 底部显示**最后更新时间**；部分城市失败时仍展示已成功结果，并提示错误信息
- 列表与温度数字更新带动画（`withAnimation`、`.contentTransition(.numericText())`）

## 技术栈

| 技术 | 用途 |
|------|------|
| SwiftUI | 界面、`.refreshable`、`.task`、空态与列表动画 |
| `@MainActor` + `@Observable` | ViewModel 持有 UI 状态并在主线程更新 |
| `async/await` | ViewModel 与 Open-Meteo API 调用 |
| `Task` / `.task` / `.refreshable` | View 层进入异步流程（ViewModel 方法为 `async`，不再内部包 `Task`） |
| `withTaskGroup` | 并发请求多个城市 |
| `Sendable` | `WeatherAPIService`、`WeatherItem` 等跨并发边界传递 |

## 环境要求

- Xcode 16 或更高版本
- iOS 17.0+
- 运行时需要网络（访问 [Open-Meteo](https://open-meteo.com)，无需 API Key）

## 快速开始

1. 克隆或下载本仓库
2. 用 Xcode 打开 `WeatherApp.xcodeproj`
3. 在 **Signing & Capabilities** 中选择你的开发团队（Team）
4. 选择模拟器或真机，按 **⌘R** 运行

命令行构建（可选）：

```bash
xcodebuild -project WeatherApp.xcodeproj -scheme WeatherApp \
  -destination 'platform=iOS Simulator,name=iPhone 17' build
```

> 若模拟器名称不同，可在 Xcode 的 **Product → Destination** 中查看可用设备名，并替换 `name=` 参数。

## 项目结构

```
WeatherApp/
├── WeatherApp.xcodeproj
└── WeatherApp/
    ├── WeatherApp.swift
    ├── Assets.xcassets
    ├── Models/
    │   └── WeatherItem.swift
    ├── Networking/
    │   └── WeatherAPIService.swift
    ├── ViewModels/
    │   └── WeatherViewModel.swift    # 状态 + 并发刷新
    └── Views/
        ├── ContentView.swift
        └── WeatherRowView.swift
```

### 分层说明

| 目录 | 职责 |
|------|------|
| **Models** | 领域模型与 `WeatherError` |
| **Networking** | 地理编码、预报请求、WMO 天气码文案（无 UI 状态） |
| **ViewModels** | UI 状态、`lastUpdated` / `lastError`、`TaskGroup` 并发调度 |
| **Views** | SwiftUI 视图，通过 `Task` / `.task` / `.refreshable` 调用 ViewModel |

## 架构与数据流

```
ContentView
    ↓  .task / .refreshable / Button → Task
WeatherViewModel (@MainActor, async loadWeather / refresh)
    ↓  performRefresh → withTaskGroup { 每城 addTask }
WeatherAPIService (Sendable, async)
    ↓
Open-Meteo API
```

1. **View** 在 `.task`、`.refreshable` 或按钮的 `Task` 中 `await viewModel.loadWeather()` / `refresh()`。
2. **ViewModel** 设置 `isLoading`，用 `withTaskGroup` 并发请求各城市；子任务内 `await` **Networking**。
3. 汇总结果后写入 `items`（按城市名排序）、`lastUpdated`、`lastError`，并用 `withAnimation` 更新列表。
4. SwiftUI 因 `@Observable` 自动刷新；`ContentView` 在底部 `safeAreaInset` 展示更新时间与错误。

### ViewModel 对外状态

| 属性 | 说明 |
|------|------|
| `items` | 已成功拉取的城市天气列表 |
| `isLoading` | 是否正在刷新 |
| `lastUpdated` | 最近一次成功刷新的时间 |
| `lastError` | 全部失败或部分失败时的提示文案 |

## 天气 API

本应用使用 [Open-Meteo](https://open-meteo.com) 免费接口：

- 地理编码：`https://geocoding-api.open-meteo.com/v1/search`
- 天气预报：`https://api.open-meteo.com/v1/forecast`

数据仅供学习与演示，请遵守 Open-Meteo 的使用条款。

## 自定义城市列表

在 `WeatherApp/ViewModels/WeatherViewModel.swift` 中修改 `defaultCities` 数组。

## License

示例项目，可自由学习与修改。
