# T13 视频播放器

## 目标

为解析得到的视频 URL 接入可播放页面。

## 已实现

- 基于 `video_player` 新增 `VideoPlayerPage`：
  - 网络 URL 初始化
  - 播放/暂停控制
  - 时间轴滑块与时长标签
  - 无效 URL 或初始化失败时的错误态
- `VideoContentPage` 接入动作：
  - `Play Video (T13)` -> `VideoPlayerPage`

## 依赖

- 新增 `video_player`，用于 Android/Web 跨平台基础播放支持。

## 边界

- 当前仅提供基础播放控制。
- 全屏与高级能力后续再扩展。
