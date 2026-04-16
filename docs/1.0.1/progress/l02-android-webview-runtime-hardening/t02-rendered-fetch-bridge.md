# 任务 02：新增 Android 渲染抓取桥

## 目标

通过 MethodChannel 调用 Android 隐藏 WebView，返回渲染后 HTML、最终 URL、Cookie 与解密结果。

## 关键改动

- 新增 `RenderedPageMethodHandler.kt` 与 `RenderedPageFetcher.kt`
- 新增 Dart 端 `rendered_page_fetcher.dart` 与结果模型
- 在 `MainActivity.kt` 注册通道
- 引入 `webview_flutter`

## 验证命令

```bash
flutter test test/features/rendered_page_fetcher_test.dart
dart analyze lib/features/rule_runtime/data/rendered_page_fetcher.dart
```

