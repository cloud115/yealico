# T18 发布检查清单（PRD 1.0.1）

## 发布前

- [ ] 当前分支为 `feat/prd-1.0.1/main`
- [ ] 工作区干净（`git status` 无未提交改动）
- [ ] `pubspec.yaml` 版本为 `1.0.1+2`
- [ ] `flutter test` 全量通过
- [ ] 已核对 1.0.1 文档（架构/QA/发布）

## 构建

- [ ] 执行：
  - `powershell -ExecutionPolicy Bypass -File .\scripts\release\build_release_artifacts.ps1 -BuildName 1.0.1 -BuildNumber 2`
- [ ] 产物存在：
  - `build/app/outputs/flutter-apk/app-release.apk`
  - `build/web/`

## 标签与 Release

- [ ] 创建注解标签：`v1.0.1`
- [ ] 推送标签：`git push origin v1.0.1`
- [ ] 创建 GitHub Release 并上传产物
- [ ] 使用 `docs/1.0.1/release/notes.md` 填写发布说明

## 发布后

- [ ] APK 安装与关键流程冒烟通过
- [ ] Web 构建可访问并完成关键流程冒烟
- [ ] 记录结果到交付记录（可新增 `delivery.md`）
