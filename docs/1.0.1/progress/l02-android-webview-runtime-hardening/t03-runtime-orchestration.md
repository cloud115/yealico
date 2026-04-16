# 任务 03：运行时抓取编排切换

## 目标

在运行时统一入口中按平台选择“直连抓取 / 渲染抓取”，并补齐反爬异常模型。

## 关键改动

- 新增 `runtime_page_fetcher.dart`
- 更新 `rule_runtime_service.dart`
- 更新 `catalog_loader.dart`（连续非网络失败 -> 限流）
- 在 `app_error_policy.dart` 增加反爬相关用户提示映射

## 验证命令

```bash
flutter test test/features/rule_runtime_service_test.dart test/features/catalog_loader_test.dart test/features/html_page_fetcher_test.dart test/core/app_error_policy_test.dart
```

