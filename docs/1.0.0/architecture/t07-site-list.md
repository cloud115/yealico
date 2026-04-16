# T07 站点列表页面

## 目标

在首页展示已导入站点及其基础元信息。

## 已实现

- 首页改为有状态页面，维护会话内站点列表。
- 导入页在用户确认后返回已校验的 `RuleImportRequest`。
- 新增 `RuleImportMapper`，将导入请求映射为 `SiteRecord`。
- 首页卡片展示字段：
  - `siteName`
  - `siteId`
  - `contentType`
  - `baseUrl`
  - `ruleVersion`
- 同一 `siteId` 重新导入会覆盖更新。

## 边界

- 当前仅内存态列表。
- 暂不引入持久化存储。
- 暂不接入目录/详情/内容浏览流程。
