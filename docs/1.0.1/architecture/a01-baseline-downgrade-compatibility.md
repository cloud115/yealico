# A01 环境基线降级兼容设计（PRD 1.0.1）

## 目标

在不改变业务目标的前提下，下调工程技术栈基线，确保团队在目标开发环境下稳定构建、分析与发布。

## 设计要点

- Flutter / Dart 基线降级到 `Flutter 3.27.4`、`Dart 3.6.2`。
- Android 构建链路对齐到 `AGP 8.1.0`、`Kotlin 1.8.22`、`Gradle 8.3`、`JDK 17`。
- 保持现有规则格式与运行时行为兼容，避免规则层破坏性变更。
- 修复与降级基线不兼容的 API 与参数命名，确保 `analyze` 与构建通过。

## 影响范围

- 工程构建与依赖约束（`pubspec.yaml`、Android Gradle 配置）。
- 开发与发布文档中的环境基线说明。

## 验证基线

- `flutter pub get`
- `flutter analyze`
- `flutter build web --release --dart-define=APP_FLAVOR=prod`
- `flutter build apk --release --build-name=1.0.1 --build-number=<构建号>`
