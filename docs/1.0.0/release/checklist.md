# 发布检查清单

## 发布前

- [ ] 工作区为干净状态
- [ ] 版本已确认（`build-name` 与 PRD 版本一致）
- [ ] `flutter --version` 显示 Flutter `3.27.4`
- [ ] `dart --version` 显示 Dart `3.6.2`
- [ ] `java -version` 显示 JDK `17`
- [ ] Android SDK 已包含：
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- [ ] 若网络受限，`HTTP_PROXY` 与 `HTTPS_PROXY` 已设为 `http://127.0.0.1:7890`
- [ ] `flutter test` 通过
- [ ] 已复核手工验收清单（`docs/1.0.0/qa/acceptance.md`）

## 构建

- [ ] 执行：
  - `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName <x.y.z> -BuildNumber <n>`
- [ ] 确认产物存在：
  - `build/app/outputs/flutter-apk/app-release.apk`
- [ ] 确认产物存在：
  - `build/web/`

## GitHub Release

- [ ] 创建标签 `v<x.y.z>`
- [ ] 推送标签
- [ ] 创建标题为 `v<x.y.z>` 的 Release
- [ ] 上传 APK
- [ ] 上传 Web 压缩包（可选）
- [ ] 使用模板 `docs/1.0.0/release/notes-template.md` 填写发布说明

## 发布后

- [ ] 冒烟安装 APK
- [ ] 冒烟运行 Web 产物
- [ ] 确认 Release 可见且附件可下载

## 构建网络要求

- [ ] 当前网络可访问 Gradle 依赖下载链路

