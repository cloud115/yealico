# 任务 06：可视化会话验证页面

## 目标

提供可见 WebView 页面用于登录/过盾，返回后刷新目录。

## 关键改动

- 新增 `site_verification_page.dart`
- 在 `site_catalog_page.dart` 添加入口与刷新逻辑

## 验证命令

```bash
flutter test test/features/site_verification_page_test.dart test/features/site_catalog_page_test.dart
```

