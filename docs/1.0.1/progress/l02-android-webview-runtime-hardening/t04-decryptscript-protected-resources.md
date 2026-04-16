# 任务 04：支持 decryptScript 与受保护资源请求

## 目标

将内容解析结果升级为携带请求头的资源对象，并优先使用 `decryptScript` 输出。

## 关键改动

- 新增 `ContentResource`
- 升级 `ContentPayload`
- 更新 `rule_runtime_engine.dart`
- 更新图片/视频 loader 返回类型

## 验证命令

```bash
flutter test test/features/rule_runtime_engine_test.dart test/features/image_content_loader_test.dart test/features/video_content_loader_test.dart test/features/content_resource_headers_test.dart
```

