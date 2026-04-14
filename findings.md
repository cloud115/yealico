# Findings

## Source Documents
- PRD: `docs/PRD/1.0.0.md`
- 外部参考: Yealico 官方站点规则文档 `https://yealico.app/site-rule-wiki/`

## Product Findings
- 当前仓库尚未初始化 Flutter 工程，处于纯规划阶段
- PRD 核心目标是通过规则驱动的站点解析，为漫画 / 图集 / 视频提供净化阅读或播放体验
- 用户后续明确收紧了 MVP 边界，避免首版做成通用浏览器或复杂规则平台

## Confirmed Constraints
- 规则文件只支持 JSON
- 一个规则文件对应一个站点
- 仅支持无需浏览器 JS 执行的站点
- 不支持 DRM
- 不支持降级回原网页浏览
- 发布方式为 GitHub Release
- 错误提示采用 dev / prod 分流，内部日志保留细节
- 技术栈改为 Flutter

## Rule Design Findings
- Yealico 的价值主要在于:
  - 分层规则结构
  - 选择器驱动的数据提取
  - 对站点解析链路的抽象
- Yealico 中不适合 MVP 直接继承的能力:
  - 浏览器 JS 执行
  - WebView 语义
  - Cookie / 登录态
  - 搜索、评论、标签、系列等扩展模型
  - 滚动加载、多级脚本执行、复杂页面跳转
- 因此当前规则应保持“受启发但不兼容”的策略

## Recommended Internal Rule Schema
- 顶层:
  - `version`
  - `meta`
  - `request`
  - `routes`
  - `indexRule`
  - `detailRule`
  - `contentRule`
- 通用抽取原语:
  - CSS selector
  - 文本 / 属性 / HTML 取值
  - regex 提取
  - replacement
  - trim
  - absolute URL 归一化
- 内容类型:
  - `comic`
  - `gallery`
  - `video`

## Technical Findings
- Flutter 侧推荐架构:
  - 状态管理: Riverpod
  - 路由: go_router
  - 网络: dio
  - HTML 解析: parser 类库
  - 存储: Isar 优先
  - 播放器: media_kit 优先
- 原因:
  - 这些选择能较好覆盖离线存储、规则执行和播放器场景
  - 同时避免 MVP 自建过多基础设施

## Delivery Findings
- 当前最适合持久化的信息分为三类:
  - `task_plan.md`: 计划、边界、任务顺序
  - `findings.md`: 需求与外部文档提炼结论
  - `progress.md`: 会话级推进记录
- 后续任意新会话开始时，优先读取这三份文件即可恢复上下文

## Open Risks
- 某些视频站点虽然表面无需 JS，但真实源提取依旧不稳定
- 规则 JSON 如果设计过于灵活，会增加校验器复杂度
- 如果早期不冻结 schema，后续任务会反复返工
- 需要在实现前最终确认:
  - 本地数据库用 `Isar` 还是 `Drift`
  - 播放器用 `media_kit` 还是 `video_player`
