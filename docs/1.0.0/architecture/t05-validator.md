# T05 规则校验器

## 目标

根据 `rule-schema-v1` 与 MVP 约束校验导入规则 JSON，并返回结构化、可诊断的错误信息。

## 已实现

- `RuleValidator`
  - 根字段必填校验
  - 字段类型校验
  - 枚举/取值支持性校验
  - 提取器校验（`text/html/attr`，`attr` 必须带 `param`）
  - 请求方法仅允许 `GET`
  - `detailUrlMode` 仅允许 `direct`
  - 按 `meta.contentType` 做内容分支校验
  - 二级嵌套约束校验
- `RuleValidationIssue`
  - `code`
  - `path`
  - `message`
- `RuleValidationResult`
  - `issues` 列表
  - `isValid` 便捷属性
- `RuleImportService` 集成
  - 校验失败时抛出携带问题列表的 `RuleValidationException`
- `RuleImportPage` 集成
  - 页面展示校验错误，便于快速定位

## 边界

- 不涉及 DB 持久化。
- 不涉及解析运行时执行。
- 不扩展导入页之外的 UI 流程。
