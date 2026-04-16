# PRD 1.0.1 Runtime Hardening 实施计划（中文版）

## 目标

将 Android 运行时从“直接 HTTP 抓取”升级为“WebView 协助渲染抓取”方案，补齐反爬站点所需能力：

- 渲染后 HTML 抽取
- Cookie 同步
- `User-Agent`/`Referer` 控制
- `decryptScript` 解密脚本执行
- 阅读器并发与节流控制

同时保持对 `v1.0.0` 规则的向后兼容。

## 架构要点

- 保留当前纯 Dart 规则解析引擎。
- Android 侧新增隐藏 WebView + MethodChannel 渲染抓取桥接。
- Flutter 运行时按平台选择抓取策略：
  - Android：优先渲染抓取
  - Web/开发代理：保持直连抓取
- 内容资源从“裸 URL 字符串”升级为“URL + 请求头”对象，确保图片/视频请求可复用 Cookie、Referer、UA。

## 计划文件变更

### 新增

- `lib/core/models/content_resource.dart`
- `lib/core/models/rendered_page_result.dart`
- `lib/features/rule_runtime/data/rendered_page_fetcher.dart`
- `lib/features/rule_runtime/data/runtime_page_fetcher.dart`
- `lib/features/rule_runtime/domain/request_profile_resolver.dart`
- `lib/features/reader/domain/image_prefetch_scheduler.dart`
- `lib/features/site_session/presentation/site_verification_page.dart`
- `android/app/src/main/kotlin/com/tclxuser/yealico/RenderedPageMethodHandler.kt`
- `android/app/src/main/kotlin/com/tclxuser/yealico/RenderedPageFetcher.kt`
- 对应单元/组件测试文件

### 修改

- `pubspec.yaml`（新增 `webview_flutter`）
- `lib/core/models/content_payload.dart`
- `lib/features/rule_import/domain/rule_validator.dart`
- `lib/features/rule_runtime/domain/rule_runtime_service.dart`
- `lib/features/rule_runtime/domain/rule_runtime_engine.dart`
- `lib/features/content/domain/*_loader.dart`
- `lib/features/content/presentation/*.dart`
- `lib/features/reader/presentation/image_reader_page.dart`
- `lib/features/player/presentation/video_player_page.dart`
- `lib/features/catalog/presentation/site_catalog_page.dart`
- `lib/core/errors/app_error_policy.dart`
- `android/app/src/main/kotlin/com/tclxuser/yealico/MainActivity.kt`
- `docs/1.0.1/PRD/schema.md` 与规则样例

## 规则契约决策

保持 `version: "1.0"` 不变，仅增加可选字段：

- `request.userAgent`
- `request.refererPolicy`（`origin`/`page`/`none`，默认 `origin`）
- `contentRule.decryptScript`

这样可保证旧规则无需改动也能运行，新能力可增量启用。

## 分任务执行

### 任务 1：扩展规则契约与请求画像

目标：让校验器接受新可选字段，并提供统一请求头计算能力。

- 修改 `rule_validator.dart`
- 新增 `request_profile_resolver.dart`
- 更新 `schema.md` 与样例 JSON
- 补充测试：
  - `rule_validator_test.dart`
  - `request_profile_resolver_test.dart`

验证命令：

```bash
flutter test test/features/rule_validator_test.dart test/features/request_profile_resolver_test.dart
```

### 任务 2：新增 Android 渲染抓取桥

目标：通过 MethodChannel 调用 Android 隐藏 WebView，返回渲染后 HTML、最终 URL、Cookie、解密结果。

- 新增 `RenderedPageMethodHandler.kt` 与 `RenderedPageFetcher.kt`
- 新增 Dart 端 `rendered_page_fetcher.dart` 与结果模型
- 在 `MainActivity.kt` 注册通道
- 引入 `webview_flutter`（后续用于可视化验证页）

验证命令：

```bash
flutter test test/features/rendered_page_fetcher_test.dart
dart analyze lib/features/rule_runtime/data/rendered_page_fetcher.dart
```

### 任务 3：运行时抓取编排切换

目标：在运行时统一入口中按平台选择“直连抓取 / 渲染抓取”，并补齐反爬异常模型。

- 新增 `runtime_page_fetcher.dart`
- 更新 `rule_runtime_service.dart`
- 更新 `catalog_loader.dart`（连续非网络失败 -> 限流）
- 在 `app_error_policy.dart` 增加反爬相关用户提示映射

验证命令：

```bash
flutter test test/features/rule_runtime_service_test.dart test/features/catalog_loader_test.dart test/features/html_page_fetcher_test.dart test/core/app_error_policy_test.dart
```

### 任务 4：支持 `decryptScript` 与受保护资源请求

目标：内容解析结果改为资源对象，携带请求头；优先使用 `decryptScript` 输出。

- 新增 `ContentResource`
- 升级 `ContentPayload`
- 更新 `rule_runtime_engine.dart`
- 更新图片/视频 loader 返回类型

验证命令：

```bash
flutter test test/features/rule_runtime_engine_test.dart test/features/image_content_loader_test.dart test/features/video_content_loader_test.dart test/features/content_resource_headers_test.dart
```

### 任务 5：阅读器/播放器请求头透传与节流

目标：图片与视频请求透传 headers；阅读器预取限制并发与节流。

- 新增 `image_prefetch_scheduler.dart`
- 更新 `image_reader_page.dart`、`video_player_page.dart`
- 更新内容页到阅读器/播放器的数据传递

验证命令：

```bash
flutter test test/features/image_reader_page_test.dart test/features/video_player_page_test.dart test/features/image_prefetch_scheduler_test.dart
```

### 任务 6：可视化会话验证页面

目标：提供可见 WebView 页用于登录/过盾，返回后刷新目录。

- 新增 `site_verification_page.dart`
- 在 `site_catalog_page.dart` 添加入口与刷新逻辑

验证命令：

```bash
flutter test test/features/site_verification_page_test.dart test/features/site_catalog_page_test.dart
```

### 任务 7：1.0.1 文档与 QA 收口

目标：补齐 1.0.1 架构文档、验收清单与测试报告。

- 新增：
  - `docs/1.0.1/architecture/t18-runtime-hardening.md`
  - `docs/1.0.1/qa/t18-acceptance.md`
  - `docs/1.0.1/qa/t18-test-report.md`
- 更新：`README.md`、`docs/README.md`、必要样例规则
- 全量回归：

```bash
flutter test
```

## 覆盖关系（PRD 对照）

- 2.1 WebView 预渲染：任务 2 + 3
- 2.2 UA/Referer/Cookie：任务 1 + 3 + 4 + 5
- 2.3 `decryptScript`：任务 4
- 2.4 预取/并发/节流/限流提示：任务 3 + 5
- 2.5 反爬错误提示：任务 3
- 第 3 章向后兼容：任务 1 + 3
- 第 4 章验收场景：任务 7

## 备注

- 本计划保持 Web 端开发代理路径不变，`1.0.1` 以 Android 加固为主。
- 最大 API 变化是内容资源模型从“字符串 URL”升级为“带 headers 的资源对象”。
- 新增依赖仅 `webview_flutter`，用于可视化会话验证页面；隐藏渲染抓取仍由原生 Android 实现。
