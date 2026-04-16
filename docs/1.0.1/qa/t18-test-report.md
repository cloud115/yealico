# T18 测试报告（PRD 1.0.1 Runtime Hardening）

## 日期

- 2026-04-16

## 自动化测试结论

- 结果：通过

## 执行命令

```bash
flutter test test/core/models_test.dart \
  test/features/rule_runtime_engine_test.dart \
  test/features/rule_runtime_service_test.dart \
  test/features/image_content_loader_test.dart \
  test/features/video_content_loader_test.dart \
  test/features/content_resource_headers_test.dart \
  test/features/image_prefetch_scheduler_test.dart \
  test/features/image_reader_page_test.dart \
  test/features/video_player_page_test.dart \
  test/features/image_content_page_test.dart \
  test/features/video_content_page_test.dart \
  test/features/site_verification_page_test.dart \
  test/features/site_catalog_page_test.dart
```

## 覆盖摘要

- `ContentResource` / `ContentPayload` 兼容与序列化
- `RuleRuntimeEngine` 的 `decryptResult` 优先策略
- 请求头透传到图片/视频资源
- loader 新接口（resource）与旧接口（url）兼容
- 阅读器预取调度器并发与节流行为
- 目录页会话验证入口与刷新路径

## 风险与后续

- 真实设备上的 WebView 登录态保持需继续做站点级验证
- 部分强反爬站点仍需规则层专项调优（UA、脚本、Referer 策略）
