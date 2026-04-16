# Yealico

面向 Android 的规则驱动 Flutter 阅读器 MVP，并提供 Web 调试支持。

## 平台范围

- 运行目标：Android App
- 开发/调试目标：Web

## 版本基线

- 当前应用版本：`1.0.1+2`（见 `pubspec.yaml`）
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

### PRD 1.0.0（已完成）

- 长任务 `L01`：MVP 主线交付（`docs/1.0.0/progress/l01-mvp-core-delivery/`）
- 任务拆分（与 `t01` ~ `t17` 文件一致）：
  - `t01`：Flutter 项目壳、dev/prod 入口、Android+Web 目标
  - `t02`：规则 schema v1 文档与样例 JSON
  - `t03`：核心数据模型与存储契约
  - `t04`：GitHub Raw 规则导入流程（下载 + 预处理 + 导入请求）
  - `t05`：结构化错误规则校验器与导入时校验
  - `t06`：运行时 HTML 请求/解析/提取引擎
  - `t07`：站点列表页与导入站点元信息展示
  - `t08`：站点目录解析与目录列表页
  - `t09`：详情解析与详情列表页
  - `t10`：图片内容解析与 URL 列表页
  - `t11`：图片阅读器（点击/滑动翻页）
  - `t12`：视频 URL 解析与展示页
  - `t13`：视频播放器接入与基础控制
  - `t14`：dev/prod 错误提示分层与内部日志策略
  - `t15`：运行时缓存与基线性能优化
  - `t16`：验收清单与测试报告准备
  - `t17`：发布流程与交付产物（web build 与 apk build 已验证）

### PRD 1.0.1（已完成）

- 长任务 `L01`：环境基线降级兼容（`docs/1.0.1/progress/l01-baseline-downgrade-compatibility/`）
  - `t01`：Flutter/Dart 与 Android 构建栈降级对齐，确保构建与分析稳定
- 长任务 `L02`：Android WebView 反爬加固（`docs/1.0.1/progress/l02-android-webview-runtime-hardening/`）
  - `t01`：扩展规则契约与请求画像
  - `t02`：新增 Android 渲染抓取桥
  - `t03`：运行时抓取编排切换
  - `t04`：支持 `decryptScript` 与受保护资源请求
  - `t05`：阅读器/播放器请求头透传与节流
  - `t06`：可视化会话验证页面
  - `t07`：文档与 QA 收口

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
- `architecture/`：按“长任务/核心动作”维护架构设计文档；单一主需求默认合并为一个文档，若同版本存在多个核心动作可并列多个文档
- `progress/`：按“长任务目录 + 单任务文档”维护进展，格式为 `progress/l<nn>-<long-task-slug>/t<nn>-<task-slug>.md`
- `qa/`：验收标准、测试记录与测试报告
- `release/`：发布流程、检查单、交付说明与版本说明

新增文档优先放到对应版本目录；跨版本通用规则样例统一放在 `docs/rules/samples/`。

## 运行

- 开发入口：`flutter run -t lib/main_dev.dart`
- 生产入口验证：`flutter run -t lib/main_prod.dart`

## Web 调试代理（FreeImages）

当目标站点触发浏览器 CORS 或上游反爬拦截时，仅用于本地 Web 调试。

1. 一键启动代理服务（推荐）：
   `powershell -ExecutionPolicy Bypass -File .\scripts\dev\start_web_debug_proxy.ps1`
   常用参数：
   `powershell -ExecutionPolicy Bypass -File .\scripts\dev\start_web_debug_proxy.ps1 -ProxyUrl 'http://127.0.0.1:7890' -FetchMode powershell -Port 8787`
   若当前网络无需上游代理：
   `powershell -ExecutionPolicy Bypass -File .\scripts\dev\start_web_debug_proxy.ps1 -NoProxy`
2. 检查健康接口：
   `http://localhost:8787/health`
3. 导入代理规则文件：
   `docs/rules/samples/freeimages-cn-gallery-rule-web-dev-proxy.json`
4. 以 dev 模式运行 Flutter Web 并打开导入站点。

注意：
- Web 调试代理仅用于本地开发，不能作为生产流量基础设施。


