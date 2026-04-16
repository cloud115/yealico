# 发布说明模板 v<version>

> `<version>` 必须与目标 PRD 版本一致。

## 版本信息

- PRD 版本：`<version>`
- App 版本：`<version>+<buildNumber>`

## 亮点

- Android 渲染抓取编排（WebView + Runtime 统一入口）
- 规则 `decryptScript` 优先解析
- 图片/视频资源请求头透传
- 阅读器预取并发与节流控制
- 目录页会话验证入口（Verify Session）

## 质量状态

- 自动化测试：`flutter test` 通过
- 重点验收：`docs/1.0.1/qa/t18-acceptance.md`
- 测试报告：`docs/1.0.1/qa/t18-test-report.md`

## 已知限制

- Web 端在本地调试阶段，部分强反爬站点可按需使用开发代理辅助（仅限调试）
- 个别站点仍需要规则专项调优
