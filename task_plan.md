# Yealico Flutter MVP Task Plan

## Goal
将已确认的 PRD、MVP 边界、规则方案与工程拆解保存为可持续执行的落地计划，保证后续会话可恢复上下文并继续推进实现。

## Current Status
- 阶段: 规划完成，待进入实现
- 当前结论: 已完成产品约束澄清、规则体系收敛、工程任务拆解
- 当前限制: 用户明确要求当前阶段不写代码

## Confirmed Scope
- 技术栈使用 Flutter 实现
- 规则文件只支持 `JSON`
- 一个规则文件对应一个站点
- MVP 只支持无需浏览器 JS 执行的站点
- MVP 不支持 DRM
- MVP 不支持失败后降级到原网页 / WebView 浏览
- GitHub Release 作为交付发布方式
- 错误提示策略:
  - 开发模式: 面向用户展示较详细错误
  - 生产模式: 面向用户展示统一提示
  - 内部日志: 两种模式都保留详细日志

## Explicit Out Of Scope
- 小说阅读
- 浏览器执行 JS
- 登录、Cookie 同步、浏览器态继承
- DRM 内容播放
- 搜索、评论、标签、收藏生态类增强功能
- 内置规则市场
- 多站点合并规则文件
- 复杂 Yealico 全量兼容

## Architecture Direction
- 应用形态: Flutter 客户端，本地导入和执行站点规则
- 规则定位: 参考 Yealico 分层思想，但采用简化内部 JSON Schema
- 运行链路:
  1. 用户导入 GitHub Raw 规则链接
  2. 下载 JSON 规则
  3. 规则校验与落库
  4. 通过 HTML 请求与解析执行规则
  5. 输出目录、详情、图片或视频地址
  6. 进入阅读器或播放器

## Rule Schema Freeze
- 顶层字段:
  - `version`
  - `meta`
  - `request`
  - `routes`
  - `indexRule`
  - `detailRule`
  - `contentRule`
- `meta`:
  - `siteId`
  - `siteName`
  - `baseUrl`
  - `contentType`: `comic` / `gallery` / `video`
- `request`:
  - `method`: MVP 固定 `GET`
  - `charset`
  - `timeoutMs`
  - `headers`
- `routes`:
  - `indexUrl`
  - `detailUrlMode`: MVP 固定 `direct`
- 通用抽取器字段:
  - `selector`
  - `function`: `text` / `html` / `attr`
  - `param`
  - `regex`
  - `replacement`
  - `trim`
  - `absoluteUrl`
- `indexRule`:
  - `item.selector`
  - `fields.title`
  - `fields.detailUrl`
  - 可选 `id`
  - 可选 `cover`
- `detailRule`:
  - 可选 `title`
  - `item.selector`
  - `fields.title`
  - `fields.url`
- `contentRule`:
  - `comic` / `gallery`: `images.item` + `images.fields.url`
  - `video`: `video.url`
  - 可选 `secondLevel`，仅允许再跳一次页面

## Compatibility Boundary
- 当前规则设计受 Yealico 文档启发，但不是 Yealico 规则的直接兼容子集
- 现阶段不承诺现有 Yealico 复杂规则可直接导入
- 如果未来需要兼容，应新增规则转换器或兼容层，不应污染当前 MVP 执行器

## Recommended Tech Choices
- UI / App: Flutter + Dart
- 状态管理: Riverpod
- 路由: go_router
- 网络: dio
- HTML 解析: HTML parser 类库
- 本地存储: 优先 `Isar`
- 视频播放器: 优先 `media_kit`

## Execution Phases

### T01 工程初始化与基础约束落地
- 目标: 创建 Flutter 工程骨架并固定基础目录、依赖策略、环境开关
- 验证: 工程可启动，存在 dev/prod 基础环境区分
- 可独立提交: 是

### T02 规则协议文档冻结与样例固化
- 目标: 将 `rule-schema-v1` 与合法 / 非法样例文档化
- 验证: 开发可以按文档写出规则样例并人工校验
- 可独立提交: 是

### T03 核心数据模型与本地存储设计
- 目标: 定义站点、规则、解析结果、阅读历史等基础模型及持久化结构
- 验证: 模型关系闭合，支持后续导入与展示
- 可独立提交: 是

### T04 规则导入链路设计
- 目标: 实现 GitHub Raw 链接输入、下载、基础预处理链路
- 验证: 能获取规则文本并形成导入请求
- 可独立提交: 是

### T05 规则校验器设计
- 目标: 对 JSON 格式、字段完整性、字段类型、MVP 限制进行校验
- 验证: 合法规则通过，非法规则返回明确校验错误
- 可独立提交: 是

### T06 HTML 解析执行器设计
- 目标: 实现统一的请求、DOM 解析、选择器抽取、URL 归一化能力
- 验证: 对样例 HTML 可得到稳定解析结果
- 可独立提交: 是

### T07 站点列表页任务
- 目标: 展示已导入站点与基础元信息
- 验证: 导入成功后站点列表可见
- 可独立提交: 是

### T08 目录解析与展示任务
- 目标: 站点首页或目录页内容抓取与展示
- 验证: 能展示规则定义的内容列表
- 可独立提交: 是

### T09 详情页解析与展示任务
- 目标: 展示章节 / 相册 / 剧集等详情列表
- 验证: 点击列表项可进入详情数据
- 可独立提交: 是

### T10 图片内容解析任务
- 目标: 提取漫画 / 图集图片地址列表
- 验证: 能得到可渲染的图片 URL 列表
- 可独立提交: 是

### T11 漫画 / 图集阅读器任务
- 目标: 实现左右翻页、页码展示、沉浸式阅读
- 验证: 支持点击和手势翻页
- 可独立提交: 是

### T12 视频内容解析任务
- 目标: 提取真实视频地址
- 验证: 规则可返回可播放的视频源
- 可独立提交: 是

### T13 视频播放器任务
- 目标: 接入播放器并全屏播放视频地址
- 验证: 支持基础播放控制与错误反馈
- 可独立提交: 是

### T14 错误提示与日志分流任务
- 目标: 实现 dev / prod 错误信息分流和内部日志记录
- 验证: 同一错误在不同模式下呈现不同用户提示，内部日志完整
- 可独立提交: 是

### T15 缓存与基础性能任务
- 目标: 添加必要缓存、超时控制、图片 / 页面基础性能优化
- 验证: 常见页面响应稳定，无明显阻塞
- 可独立提交: 是

### T16 验收清单与手工测试任务
- 目标: 基于 PRD 和补充边界整理测试矩阵并完成手工验收
- 验证: 每条 MVP 能力均有验收结果
- 可独立提交: 是

### T17 GitHub Release 交付任务
- 目标: 形成可发布包、发布说明和交付流程
- 验证: 可按 GitHub Release 流程交付 MVP
- 可独立提交: 是

## Recommended Next Step
- 下一步从 `T01` 开始进入实现
- 进入实现前，先在仓库补一份规则协议文档，避免实现期口径漂移

## Risks To Track
- 规则过度追求 Yealico 兼容，导致 MVP 边界失控
- 视频站点真实地址提取差异大，可能需要更严格的站点准入标准
- 无浏览器 JS 约束下，可支持站点范围可能小于预期
- Flutter 播放器方案对部分视频源兼容性可能不足
- HTML 结构脆弱，规则维护成本需在后续版本继续评估

## Errors Encountered
- 当前无实现错误
- 唯一已知问题: PRD 原文件在终端读取时存在编码显示异常，但不影响已完成的需求澄清与规划沉淀
