# T17 GitHub 发布流程

## 目标

定义可重复执行的 MVP 发布交付流程。

## 发布输入

- 源分支：`main`
- 版本信息：
  - 应用版本（`build-name`，需与 PRD 版本一致）
  - 构建号（`build-number`）
- 变更说明（changelog）

## 构建环境

- Flutter SDK：`3.27.4`
- Dart SDK：`3.6.2`
- JDK：`17`
- Android SDK 包：
  - `platform-tools`
  - `platforms;android-35`
  - `build-tools;35.0.0`
  - `ndk;26.1.10909125`
- 若当前网络受限，请在发布构建前导出 `HTTP_PROXY` 与 `HTTPS_PROXY` 为 `http://127.0.0.1:7890`。

## 构建产物

- Android APK：
  - `build/app/outputs/flutter-apk/app-release.apk`
- Web 产物：
  - `build/web/`

构建脚本：

- `scripts/release/build_release_artifacts.ps1`

## 发布步骤

1. 确认工作区干净且测试通过
- `flutter test`

2. 构建发布产物
- `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName <x.y.z> -BuildNumber <n>`

3. 准备发布说明
- 使用模板：
  - `docs/1.0.0/release/notes-template.md`

4. 创建 Git Tag
- `git tag v<x.y.z>`
- `git push origin v<x.y.z>`

5. 创建 GitHub Release
- 标题：`v<x.y.z>`
- 附件：
  - APK
  - （可选）`build/web` 的 zip
- 粘贴发布说明

6. 发布后验证
- 从 Release 页面下载 APK 并安装验证
- 将 Web 产物部署到静态托管并执行冒烟验证

## 回滚指引

- 若发布无效：
  - 将 Release 标记为 pre-release 或 draft
  - 从下一个补丁版本（`x.y.z+1`）发布热修复
