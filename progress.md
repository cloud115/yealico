# Progress Log

## 2026-04-16 Session

### Completed
- 将仓库 Flutter/Dart 基线整体下调到 Flutter `3.27.4` / Dart `3.6.2`
- 将 Android 构建链回调到 AGP `8.1.0`、Kotlin `1.8.22`、Gradle `8.3`
- 更新 README、docs README 与 release 文档中的开发环境基线说明
- 在 macOS `12.7.6` Intel 机器上补齐用户目录下的 JDK `17` 与 Android SDK
- 修复 downgrade 后暴露的少量 Dart 回调参数命名兼容问题与一个弃用颜色 API
- 新增进度记录 `docs/progress/2026-04-16-environment-baseline-downgrade.md`

### Validation
- `flutter pub get` 通过
- `flutter analyze` 通过
- `flutter build web --release --dart-define=APP_FLAVOR=prod` 通过
- `flutter build apk --release --build-name=1.0.0 --build-number=1` 通过
- `flutter test` 通过

### Current State
- 当前仓库公开开发基线已与 macOS 12 Intel 本机环境对齐
- Web 与 Android APK 均已在当前机器完成验证
- 本机 Android SDK 路径为 `~/Library/Android/sdk`
- 本机 JDK 路径为 `~/.local/jdks/jdk-17.0.18+8/Contents/Home`

### Notes
- `android/local.properties` 已在本机生成，但被 `android/.gitignore` 忽略，不会入库
- 全局 `flutter config` 已指向上述本机 JDK 与 Android SDK

## 2026-04-14 Session

### Completed
- 阅读并分析 PRD `docs/PRD/1.0.0.md`
- 明确用户要求当前阶段不要写代码
- 将需求拆解为工程模块
- 明确 MVP 开发边界与非目标范围
- 识别不明确点和风险点
- 形成可执行技术方案概要
- 根据 Yealico 官方规则文档，收敛并优化内部规则设计
- 固化简化版 `rule-schema-v1` 思路
- 输出可逐步完成的工程任务清单 `T01` 至 `T17`
- 将当前计划、发现和进度持久化到仓库文件

### Current State
- 尚未开始编码
- 尚未初始化 Flutter 工程
- 当前已经具备进入实现阶段所需的总体任务清单

### Next Recommended Action
- 用户确认后，从 `T01 工程初始化与基础约束落地` 开始执行

### Notes
- 如果后续会话恢复，需要先读取:
  - `task_plan.md`
  - `findings.md`
  - `progress.md`
- 这三份文件应作为当前项目的持久化工作记忆
