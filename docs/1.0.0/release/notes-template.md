# 发布说明 v<version>

版本提示：`<version>` 需要与当前生效的 PRD 版本一致。

## 亮点

- 支持从 GitHub Raw URL 导入规则
- 规则校验与 dev/prod 错误策略
- 目录/详情/内容解析流程打通
- 图片阅读器体验
- 视频 URL 解析与基础播放入口

## 包含范围

- 01-17 主线任务（实现 + QA + 发布流程）

## 构建产物

- Android APK：`app-release.apk`
- Web 产物：`build/web`（可选以 zip 形式附加）

## 验证

- 自动化测试：`flutter test` 通过
- 手工清单：`docs/1.0.0/qa/acceptance.md`

## 已知限制

- 依赖浏览器 JS 的站点暂不支持
- 不支持回退到原网页/WebView
- 小说/文本阅读不在 MVP 范围内

## 升级说明

- 建议在 MVP 基线下全新安装
- 规则文件必须符合 `rule-schema-v1`

