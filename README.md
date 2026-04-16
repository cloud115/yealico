# Yealico

面向 Android 的规则驱动 Flutter 阅读器 MVP，并提供 Web 调试支持。

## 平台范围

- 运行目标：Android App
- 开发/调试目标：Web
- 当前仓库不维护：Windows 桌面端（`windows/` 目录已移除）

## 版本基线

- 当前应用版本：`1.0.0+1`（见 `pubspec.yaml`）
- 文档根索引：`docs/README.md`
- 已归档 PRD 版本：`1.0.0`、`1.0.1`
- 版本约束：
  - `pubspec.yaml` 中 `build-name` 必须与目标 PRD 版本一致
  - `build-number` 按内部构建号持续递增

## 开发环境基线

- Flutter SDK：`3.27.4`
- Dart SDK：`3.6.2`
- Android 构建 JDK：`17`
- Android SDK 包：
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- 受限网络代理：
  - Shell `HTTP_PROXY` / `HTTPS_PROXY`：`http://127.0.0.1:7890`
  - Gradle 代理已在 `android/gradle.properties` 配置

## 当前阶段

- `T01` 已完成：Flutter 项目壳、dev/prod 入口、Android+Web 目标。
- `T02` 已完成：规则 schema v1 文档与样例 JSON。
- `T03` 已完成：核心数据模型与存储契约。
- `T04` 已完成：GitHub Raw 规则导入流程（下载 + 预处理 + 导入请求）。
- `T05` 已完成：结构化错误规则校验器与导入时校验。
- `T06` 已完成：运行时 HTML 请求/解析/提取引擎。
- `T07` 已完成：站点列表页与导入站点元信息展示。
- `T08` 已完成：站点目录解析与目录列表页。
- `T09` 已完成：详情解析与详情列表页。
- `T10` 已完成：图片内容解析与 URL 列表页。
- `T11` 已完成：图片阅读器（点击/滑动翻页）。
- `T12` 已完成：视频 URL 解析与展示页。
- `T13` 已完成：视频播放器接入与基础控制。
- `T14` 已完成：dev/prod 错误提示分层与内部日志策略。
- `T15` 已完成：运行时缓存与基线性能优化。
- `T16` 已完成：验收清单与测试报告准备。
- `T17` 已完成：发布流程与交付产物（web build 与 apk build 已验证）。
- `T18` 已完成：PRD 1.0.1 runtime hardening（渲染抓取编排、资源请求头透传、会话验证入口）。

## 文档导航

- 文档总览：`docs/README.md`
- `1.0.0` 版本索引：`docs/1.0.0/README.md`
- `1.0.1` 版本索引：`docs/1.0.1/README.md`
- `PRD 1.0.0`：`docs/1.0.0/PRD/prd.md`
- `PRD 1.0.1`：`docs/1.0.1/PRD/prd.md`
- 规则 schema 与样例：`docs/1.0.1/PRD/schema.md`、`docs/rules/samples/`

## 文档结构规范

项目文档统一采用 `docs/<version>/<category>/...` 结构，每个版本目录按以下分类组织：

- `PRD/`：需求文档与规则 schema
- `architecture/`：架构设计与任务技术方案
- `progress/`：任务计划、环境基线与进展记录
- `qa/`：验收标准、测试记录与测试报告
- `release/`：发布流程、检查单、交付说明与版本说明

新增文档优先放到对应版本目录；跨版本通用规则样例统一放在 `docs/rules/samples/`。

## 运行

- 开发入口：`flutter run -t lib/main_dev.dart`
- 生产入口验证：`flutter run -t lib/main_prod.dart`

## Web 调试代理（FreeImages）

当目标站点阻止浏览器 CORS 时，仅用于本地 Web 调试。

1. 启动代理服务：
   `node scripts/dev/freeimages_proxy_server.mjs`
   FreeImages 推荐方式（PowerShell + 上游代理）：
   `$env:UPSTREAM_FETCH_MODE='powershell'; $env:HTTPS_PROXY='http://127.0.0.1:7890'; node scripts/dev/freeimages_proxy_server.mjs`
2. 检查健康接口：
   `http://localhost:8787/health`
3. 导入代理规则文件：
   `docs/rules/samples/freeimages-cn-gallery-rule-web-dev-proxy.json`
4. 以 dev 模式运行 Flutter Web 并打开导入站点。

## Android 调试代理（FreeImages）

当目标站点对 Dart/Node 请求指纹返回 `403` 时，将 Android 请求同样路由到本地代理：

1. 在主机启动代理服务（同上）。
2. Android 模拟器导入：
   `docs/rules/samples/freeimages-cn-gallery-rule-android-dev-proxy.json`
3. 真机调试时，将该规则中的 `10.0.2.2` 替换为主机局域网 IP。

Android 说明：
- `debug/profile` manifest 已允许本地 `http://` 调试代理明文流量。
- 直连规则（`https://www.freeimages.com/...`）在 Android 仍可能因上游反爬返回 `403`，开发验证请使用代理规则。

注意：
- 该代理仅用于本地开发，不能作为生产流量基础设施。
- 上游模式选项：`UPSTREAM_FETCH_MODE=auto|node|powershell`（默认 `auto`）。
- Android 非 Web 直连规则文件仍保留：
  `docs/rules/samples/freeimages-cn-gallery-rule.json`
