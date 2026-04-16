# T18 Runtime Hardening 架构说明（PRD 1.0.1）

## 目标

在不破坏 `1.0.0` 规则兼容性的前提下，提升 Android 站点抓取成功率，核心覆盖：

- 渲染页抓取（WebView）
- UA/Referer/Cookie 同步
- `decryptScript` 解析分流
- 受保护媒体资源请求头透传
- 阅读器预取并发与节流
- 会话验证页面（登录/过盾）

## 关键设计

### 1. 运行时抓取编排

`RuleRuntimeService` 统一调用 `RuntimePageFetcher`，按平台策略获取页面内容：

- Android：优先渲染抓取链路（MethodChannel -> 隐藏 WebView）
- 其他场景：直接 HTTP 抓取

`RuntimePageResult` 输出：

- `html`
- `finalUri`
- `cookies`
- `requestHeaders`
- `decryptResult`
- `challengeDetected`

### 2. 内容模型升级

新增 `ContentResource`（`url + headers`），`ContentPayload` 升级为：

- `resources`（图片/图集）
- `video`（视频）

同时保留 `imageUrls` / `videoUrl` 兼容 getter，避免一次性改坏旧调用方。

### 3. `decryptScript` 优先级

`RuleRuntimeEngine.parseContent()` 新增：

- `decryptResult`
- `requestHeaders`

解析策略：

1. 若有 `decryptResult`，优先按解密结果构建 `ContentPayload`
2. 否则回退 CSS selector 提取
3. 两条路径都统一产出 `ContentResource`，并透传请求头

异常策略：

- 解密结果 JSON 非法或结构不符时抛 `DecryptScriptExecutionException`

### 4. 阅读器与播放器资源请求

- `ImageReaderPage` 改为消费 `List<ContentResource>`
- `Image.network` 使用 `headers`
- `VideoPlayerPage` 通过 `VideoPlayerController.networkUrl(..., httpHeaders: ...)` 传递请求头

### 5. 预取调度器

新增 `ImagePrefetchScheduler`：

- 默认并发上限：3
- 默认节流：200ms

阅读器预取窗口：当前页 `-2/-1/+1/+2`。

### 6. 会话验证流

新增 `SiteVerificationPage`（可见 WebView 页面）：

- 入口：`SiteCatalogPage` 顶部 `Verify Session`
- 完成动作：`Done and Refresh`
- 返回 `true` 时触发目录页重载

## 向后兼容

- 规则版本仍为 `1.0`
- 未配置 `decryptScript` / `userAgent` / `refererPolicy` 时使用默认行为
- 页面层仍保留旧 URL 访问接口（由 loader 兼容桥接）

## 已知限制

- Web 端在本地调试阶段，部分强反爬站点可按需使用开发代理辅助（仅限调试）
- 当前会话验证主要面向 Android 真实运行环境
