# T09 详情解析与展示

## 目标

从选中的目录项解析并展示详情层条目（章节/相册/剧集）。

## 已实现

- 新增 `DetailLoader` 抽象与 `RuntimeDetailLoader` 实现。
- 新增 `DetailListPage`：
  - 异步加载详情
  - 加载/错误/空态/列表态
  - 详情条目元信息渲染（`title`、`url`）
- 连接目录项动作：
  - `Open Details (T09)` -> `DetailListPage`

## 边界

- 本步骤仅展示详情列表。
- 不包含内容解析页面接入（`T10+`）。
- 不包含持久化接入。
