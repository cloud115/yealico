# 任务 05：阅读器/播放器请求头透传与节流

## 目标

图片与视频请求透传 headers；阅读器预取限制并发与节流。

## 关键改动

- 新增 `image_prefetch_scheduler.dart`
- 更新 `image_reader_page.dart`、`video_player_page.dart`
- 更新内容页到阅读器/播放器的数据传递

## 验证命令

```bash
flutter test test/features/image_reader_page_test.dart test/features/video_player_page_test.dart test/features/image_prefetch_scheduler_test.dart
```

