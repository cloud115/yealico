# 进展 - 2026-04-16（环境基线降级）

## 已完成

- 将仓库技术基线下调至 Flutter `3.27.4`、Dart `3.6.2`
- 对齐 Android Gradle 构建栈到 AGP `8.1.0`、Kotlin `1.8.22`、Gradle `8.3`
- 按降级后的工具链更新开发与发布文档
- 在 macOS 12 Intel 环境配置本地 Java `17` 与 Android SDK 工具链
- 修复回调参数命名与一处弃用颜色 API，使降级基线可通过分析与 Web 编译

## 验证

- `flutter pub get`：通过
- `flutter analyze`：通过
- `flutter build web --release --dart-define=APP_FLAVOR=prod`：通过
- `flutter build apk --release --build-name=1.0.0 --build-number=1`：通过

## 环境信息

- 主机系统：macOS `12.7.6`
- CPU 架构：`x86_64`
- Flutter SDK：`3.27.4`
- Dart SDK：`3.6.2`
- Android 构建 JDK：`17.0.18`
- Android SDK 根目录：`/Users/Jerry/Library/Android/sdk`
