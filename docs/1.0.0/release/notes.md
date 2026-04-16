# 发布说明 v1.0.0

这是 Yealico MVP 的 PRD `1.0.0` 基线版本发布。

## 亮点

- GitHub Raw 规则导入流程可用。
- 规则校验与 dev/prod 错误策略已实现。
- 站点列表、目录列表、详情列表、内容解析已端到端打通。
- 图片阅读器与视频播放入口可用。
- 发布流程、QA 清单与交付产物已文档化。

## 包含范围

- `01` 到 `17` 的主线任务
- 功能实现
- 自动化验证
- 发布流程资产

## 构建产物

- Android APK：`build/app/outputs/flutter-apk/app-release.apk`
- Web 产物：`build/web/`

## 验证

- 自动化测试：`flutter test`
- 手工清单：`docs/1.0.0/qa/acceptance.md`
- 交付报告：`docs/1.0.0/release/delivery.md`

## 已知限制

- 直接规则运行时不支持依赖 JavaScript 的站点。
- WebView/原网页回退仍不在范围内。
- 小说/文本阅读不在本基线范围内。

## 版本信息

- PRD 版本：`1.0.0`
- 应用发布版本：`1.0.0`
- 构建号：`1`

