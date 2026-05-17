# WeatherApp

一款使用 SwiftUI 编写的 iOS 天气示例应用，采用常见的 **ViewModel 集中状态** 架构，演示 **async/await 网络请求**、**Task / TaskGroup 并发** 与 **@MainActor**。

## 功能

- 并发请求多个城市当前天气（默认：北京、上海、东京、纽约、伦敦、巴黎）
- 列表展示温度、湿度、风速与天气描述
- 工具栏刷新按钮重新加载
- 部分城市失败时仍展示已成功结果，并在底部提示错误信息

## 技术栈

| 技术 | 用途 |
|------|------|
| SwiftUI | 界面与导航 |
| `@MainActor` + `@Observable` | ViewModel 持有 UI 状态并在主线程更新 |
| `async/await` | 调用 Open-Meteo API |
| `Task` | 从按钮 / 视图生命周期进入异步流程 |
| `withTaskGroup` | 并发请求多个城市 |

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
cd WeatherApp
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
| **Models** | 领域模型与错误类型 |
| **Networking** | HTTP 请求与 JSON 解析（无 UI 状态） |
| **ViewModels** | UI 状态、加载逻辑、`TaskGroup` 并发调度 |
| **Views** | SwiftUI 视图，只绑定 ViewModel |

## 架构与数据流

```
ContentView
    ↓  .task / 按钮
WeatherViewModel (@MainActor)
    ↓  Task { await refresh() }
    ↓  withTaskGroup { 每城 addTask }
WeatherAPIService (async)
    ↓
Open-Meteo API
```

1. **View** 调用 ViewModel 的 `loadWeather()` 或 `refresh()`。
2. **ViewModel** 用 `Task` 进入异步方法，更新 `isLoading`，再通过 `withTaskGroup` 并发请求各城市。
3. 子任务内 `await` **Networking**；结果汇总后直接在主线程写入 `items`、`lastError`。
4. SwiftUI 因 `@Observable` 自动刷新列表。

## 天气 API

本应用使用 [Open-Meteo](https://open-meteo.com) 免费接口：

- 地理编码：`https://geocoding-api.open-meteo.com/v1/search`
- 天气预报：`https://api.open-meteo.com/v1/forecast`

数据仅供学习与演示，请遵守 Open-Meteo 的使用条款。

## 自定义城市列表

在 `WeatherApp/ViewModels/WeatherViewModel.swift` 中修改 `defaultCities` 数组。

## License

示例项目，可自由学习与修改。
