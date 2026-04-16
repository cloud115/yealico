# GitHub 发布流程（PRD 1.0.1）

## 目标

定义 PRD 1.0.1 的可重复发布流程，确保版本、构建参数与文档一致。

## 发布输入

- 源分支：`feat/prd-1.0.1/main`
- 目标版本：
  - `build-name`: `1.0.1`
  - `build-number`: `2`（在 `1.0.0+1` 基础上递增）
- 发布说明：`docs/1.0.1/release/notes.md`

## 环境基线

- Flutter SDK：`3.27.4`
- Dart SDK：`3.6.2`
- Android JDK：`17`
- Android SDK：
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`

## 发布步骤

1. 运行测试并确认通过
- `flutter test`

2. 生成发布产物
- `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName 1.0.1 -BuildNumber 2`

3. 校验产物
- APK：`build/app/outputs/flutter-apk/app-release.apk`
- Web：`build/web/`

4. 创建并推送标签（必须与 PRD 版本一致）
- `git tag -a v1.0.1 -m "release: v1.0.1"`
- `git push origin v1.0.1`

5. 创建 GitHub Release
- 标题：`v1.0.1`
- 附件：APK、可选 Web zip
- 文案：使用 `docs/1.0.1/release/notes.md`

6. 发布后验证
- 安装 APK 冒烟验证
- Web 产物冒烟验证

## 回滚策略

- 如发现严重问题：
  - 将 Release 标记为 pre-release/draft
  - 使用补丁版本 `1.0.2` 发布修复版本

