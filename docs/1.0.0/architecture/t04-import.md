# T04 规则导入流程

## 目标

实现 MVP 导入链路：

1. 用户输入 GitHub Raw URL
2. 应用下载原始文本
3. 应用预处理内容
4. 组装 `RuleImportRequest`

本步骤有意不包含 schema 校验与持久化。

## 已实现组件

- `RuleImportRequest` 模型
  - 来源 URL
  - 归一化后的原始 JSON
  - 解析后的 JSON Map
  - 导入时间戳
- `RuleRawFetcher`
  - HTTP 下载抽象
- `RuleImportService`
  - 输入校验
  - GitHub Raw 域名校验
  - 响应状态校验
  - BOM 去除与 trim
  - JSON 解码与根对象校验
- `RuleImportPage`
  - 文本输入
  - 导入按钮
  - 成功/失败信息展示

## 边界

- 不做 schema 字段级校验（留到 `T05`）。
- 不写入存储（仅使用 `T03` 契约）。
- 不接入站点列表（留到 `T07`）。
