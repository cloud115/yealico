# T14 错误与日志策略

## 目标

实现 dev/prod 面向用户错误分层，以及统一内部日志能力。

## 已实现

- 新增运行时配置：
  - `lib/core/config/app_runtime.dart`
  - 在 bootstrap 阶段初始化
- 新增内部日志组件：
  - `lib/core/logging/app_logger.dart`
- 新增用户错误策略：
  - `lib/core/errors/app_error_policy.dart`
  - dev 模式展示详细错误
  - prod 模式展示通用兜底文案
- 将策略应用到页面流程：
  - 首页导入映射错误 snackbar
  - 导入页错误渲染
  - 目录/详情/图片/视频异步加载错误态
  - 视频播放器初始化错误
- 校验问题明细仅在 dev 模式展示。

## 边界

- 当前日志仅写入调试输出。
- 本步骤不包含持久化/远端日志通道。
