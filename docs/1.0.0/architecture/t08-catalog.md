# T08 目录解析与展示

## 目标

针对已导入站点，拉取索引页 HTML 并展示解析后的目录条目。

## 已实现

- 新增 `CatalogLoader` 抽象与 `RuntimeCatalogLoader` 实现。
- 新增 `SiteCatalogPage`：
  - 异步加载目录
  - 加载/错误/空态/列表态
  - 基础条目元信息渲染（`id`、`title`、`detailUrl`、可选 `cover`）
- 首页站点卡片增加入口：`Open Catalog (T08)`。

## 边界

- 本步骤仅覆盖索引/目录列表。
- 不包含详情解析 UI（`T09`）。
- 不包含图片/视频内容 UI（`T10+`）。
