# T03 数据模型与本地存储设计

## 目标

定义稳定的核心实体与存储接口，用于：

- 站点与规则持久化
- 解析结果传输对象
- 阅读历史持久化

本步骤仅冻结契约，不选择也不实现具体数据库引擎。

## 核心实体

### `ContentType`

- 枚举：`comic`、`gallery`、`video`
- 与 `rule-schema-v1` 的 `meta.contentType` 对齐

### `RuleSnapshot`

- `version`
- `sourceUrl`
- `rawJson`
- `importedAt`

### `SiteRecord`

- `siteId`（稳定标识）
- `siteName`
- `baseUrl`
- `contentType`
- `rule`（`RuleSnapshot`）
- `createdAt`
- `updatedAt`
- `isEnabled`

### 解析结果 DTO

- `CatalogEntry`：目录/索引结果
- `DetailEntry`：章节/相册/剧集条目
- `ContentPayload`：最终可读/可播内容
  - `comic/gallery` 使用图片 URL 列表
  - `video` 使用视频 URL

### `ReadingHistoryEntry`

- `siteId`
- `itemId`
- `itemTitle`
- `detailUrl`
- `progressIndex`
- `lastContentUrl`
- `updatedAt`

## 存储接口

- `SiteStore`
  - 站点记录 list/get/upsert/remove
- `RuleStore`
  - 规则快照 get/save/remove
- `ReadingHistoryStore`
  - 阅读历史 list/get/upsert/remove
- `AppStorage`
  - 聚合访问入口：`sites`、`rules`、`history`

## 设计决策

- 当前模型序列化统一使用 `Map<String, Object?>`。
- 在 `T03` 保持存储层与 DB 引擎无关。
- 具体数据库选型（`Isar` 或 `Drift`）延后到引入持久化实现的任务。

## T03 非目标

- 不引入数据库依赖。
- 不提供迁移脚本。
- 不实现仓储层。
- 不实现解析/网络/业务流程。
